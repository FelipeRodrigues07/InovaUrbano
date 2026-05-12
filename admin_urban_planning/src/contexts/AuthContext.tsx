import React, {
  createContext,
  useState,
  useEffect,
  useContext,
} from 'react';
import type { ReactNode } from 'react';
import axios from 'axios';
import { api } from '@/services/api/api';
import { storageAuthToken } from '@/storage/storageAuthToken';
import { storageUser } from '@/storage/storageUser';

export interface UserProfile {
  id: string;
  email: string;
  name: string;
  profilePictureUrl: string;
}

interface AuthContextType {
  token: string | null;
  userProfile: UserProfile | null;
  isLoadingUserStorageData: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  fetchProfile: () => Promise<UserProfile>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [token, setToken] = useState<string | null>(null);
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [isLoadingUserStorageData, setIsLoadingUserStorageData] = useState<boolean>(true);


  const loadUserData = async () => {
    setIsLoadingUserStorageData(true);
    try {
      const storedToken = storageAuthToken.getAuthToken();
      const storedUserProfile = storageUser.getUserProfile();

      if (storedToken) {
        setToken(storedToken);
        api.defaults.headers.common['Authorization'] = `Bearer ${storedToken}`;
      } else {
        delete api.defaults.headers.common['Authorization'];
      }

      if (storedUserProfile) {
        setUserProfile(storedUserProfile);
      }
      console.log('Token após carregar:', storedToken);
      console.log('Perfil carregado:', storedUserProfile);
    } catch (error) {
      console.error('Erro ao carregar dados do usuário do storage:', error);
      storageAuthToken.removeAuthToken();
      storageUser.removeUserProfile();
      setToken(null);
      setUserProfile(null);
      delete api.defaults.headers.common['Authorization'];
    } finally {
      setIsLoadingUserStorageData(false);
    }
  };

  useEffect(() => {
    loadUserData();
  }, []);

  const signIn = async (email: string, password: string) => {
    try {
      const response = await api.post<{ token: string; userProfile?: UserProfile }>('/authenticate', { email, password });
      const newToken = response.data.token;
      console.log('Token recebido:', newToken);

      await storageAuthToken.setAuthToken(newToken);
      setToken(newToken);
      api.defaults.headers.common['Authorization'] = `Bearer ${newToken}`;

      if (response.data.userProfile) {
        await storageUser.setUserProfile(response.data.userProfile);
        setUserProfile(response.data.userProfile);
      } else {
        await fetchProfile();
      }
    } catch (error) {
      console.error('Falha na autenticação:', error);
      await storageAuthToken.removeAuthToken();
      await storageUser.removeUserProfile();
      setToken(null);
      setUserProfile(null);
      delete api.defaults.headers.common['Authorization'];
      throw error;
    }
  };

  const fetchProfile = async (): Promise<UserProfile> => {
    if (!token) {
      const storedToken = storageAuthToken.getAuthToken();
      if (!storedToken) {
        await signOut();
        throw new Error('Usuário não autenticado. Token ausente para buscar perfil.');
      }
      api.defaults.headers.common['Authorization'] = `Bearer ${storedToken}`;
      setToken(storedToken);
    }

    try {
      const response = await api.get<UserProfile>('/profile');
      const profileData = response.data;
      console.log('Dados do perfil recebidos:', profileData);
      await storageUser.setUserProfile(profileData);
      setUserProfile(profileData);
      return profileData;
    } catch (error) {
      console.error('Erro ao buscar o perfil:', error);
      if (axios.isAxiosError(error) && error.response?.status === 401) {
        console.warn('Token inválido ou expirado ao buscar perfil. Realizando logout.');
        signOut();
      }
      throw error;
    }
  };

  const signOut = async () => {
    setIsLoadingUserStorageData(true);
    try {
      setToken(null);
      setUserProfile(null);
      await storageAuthToken.removeAuthToken();
      await storageUser.removeUserProfile();
      delete api.defaults.headers.common['Authorization'];
      console.log('Token após limpeza:', null);
    } catch (error) {
      console.error('Erro ao fazer logout:', error);
      throw error;
    } finally {
      setIsLoadingUserStorageData(false);
    }
  };


  const contextValue: AuthContextType = {
    token,
    userProfile,
    isLoadingUserStorageData,
    signIn,
    signOut,
    fetchProfile,
  };

  return (
    <AuthContext.Provider value={contextValue}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
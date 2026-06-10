import React, {
  createContext,
  useState,
  useEffect,
  useContext,
} from 'react';
import type { ReactNode } from 'react';
import axios from 'axios';
import { api } from '@/services/api/api';
import {
  clearAuthSession,
  logoutRemote,
  persistAuthTokens,
  type AuthTokensResponse,
} from '@/services/api/authSession';
import { storageAuthToken } from '@/storage/storageAuthToken';
import { storageUser } from '@/storage/storageUser';

export interface UserProfile {
  id: string;
  email: string;
  name: string;
  profilePictureUrl: string;
  role: string;
  municipalityId?: string | null;
  ibgeId?: number | null;
  municipalityName?: string | null;
  municipalityState?: string | null;
}

interface AuthContextType {
  token: string | null;
  userProfile: UserProfile | null;
  isLoadingUserStorageData: boolean;
  signIn: (email: string, password: string) => Promise<UserProfile>;
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
  const [isLoadingUserStorageData, setIsLoadingUserStorageData] =
    useState<boolean>(true);

  const loadUserData = async () => {
    setIsLoadingUserStorageData(true);
    try {
      const storedToken = storageAuthToken.getAuthToken();
      const storedUserProfile = storageUser.getUserProfile();

      if (storedToken) {
        setToken(storedToken);
        api.defaults.headers.common.Authorization = `Bearer ${storedToken}`;
        await fetchProfile();
      } else {
        delete api.defaults.headers.common.Authorization;
        if (storedUserProfile) {
          setUserProfile(storedUserProfile);
        }
      }
    } catch (error) {
      console.error('Erro ao carregar dados do usuário do storage:', error);
      clearAuthSession();
      await storageUser.removeUserProfile();
      setToken(null);
      setUserProfile(null);
    } finally {
      setIsLoadingUserStorageData(false);
    }
  };

  useEffect(() => {
    loadUserData();
  }, []);

  const signIn = async (email: string, password: string): Promise<UserProfile> => {
    try {
      const response = await api.post<AuthTokensResponse>('/authenticate', {
        email,
        password,
      });

      persistAuthTokens(response.data);
      setToken(response.data.token);

      return await fetchProfile();
    } catch (error) {
      clearAuthSession();
      await storageUser.removeUserProfile();
      setToken(null);
      setUserProfile(null);
      throw error;
    }
  };

  const fetchProfile = async (): Promise<UserProfile> => {
    try {
      const response = await api.get<UserProfile>('/profile');
      const profileData = response.data;
      await storageUser.setUserProfile(profileData);
      setUserProfile(profileData);
      setToken(storageAuthToken.getAuthToken());
      return profileData;
    } catch (error) {
      if (axios.isAxiosError(error) && error.response?.status === 401) {
        await signOut();
      }
      throw error;
    }
  };

  const signOut = async () => {
    setIsLoadingUserStorageData(true);
    try {
      await logoutRemote();
      setToken(null);
      setUserProfile(null);
      await storageUser.removeUserProfile();
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
    <AuthContext.Provider value={contextValue}>{children}</AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

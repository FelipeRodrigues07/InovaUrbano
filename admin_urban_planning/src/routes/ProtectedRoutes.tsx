import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext'; 

const ProtectedRoute: React.FC = () => {
  const { token, userProfile, isLoadingUserStorageData } = useAuth();

  if (isLoadingUserStorageData) {
    return (
      <div className="flex items-center justify-center min-h-screen text-xl">
        Carregando dados do usuário...
      </div>
    );
  }

  const isAuthenticated = !!token && !!userProfile;

  return isAuthenticated ? <Outlet /> : <Navigate to="/login" replace />;
};

export default ProtectedRoute;
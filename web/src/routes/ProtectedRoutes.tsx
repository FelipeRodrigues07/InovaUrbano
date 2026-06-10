import React from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { canAccessAdminPanel } from '@/lib/userRoles';

const ProtectedRoute: React.FC = () => {
  const { token, userProfile, isLoadingUserStorageData } = useAuth();
  const location = useLocation();

  if (isLoadingUserStorageData) {
    return (
      <div className="flex items-center justify-center min-h-screen text-xl">
        Carregando dados do usuário...
      </div>
    );
  }

  const isAuthenticated = !!token && !!userProfile;

  if (!isAuthenticated) {
    return <Navigate to="/login" replace state={{ from: location }} />;
  }

  if (!canAccessAdminPanel(userProfile.role)) {
    return (
      <Navigate
        to="/login"
        replace
        state={{
          error:
            'Sua conta não tem permissão para acessar o painel administrativo.',
        }}
      />
    );
  }

  return <Outlet />;
};

export default ProtectedRoute;

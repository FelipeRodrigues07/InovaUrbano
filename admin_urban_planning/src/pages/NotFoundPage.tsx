import React from 'react';
import { useNavigate } from 'react-router-dom';

export const NotFoundPage: React.FC = () => {
  const navigate = useNavigate();

  const handleGoHome = () => {
    navigate('/'); 
  };

  return (
    <div className="flex items-center justify-center h-screen w-full bg-gray-100 font-sans">
      <div className="text-center p-8 bg-white rounded-lg shadow-xl max-w-md w-full">
        <h1 className="text-9xl font-extrabold text-red-600 mb-4 animate-bounce">
          404
        </h1>
        <p className="text-2xl md:text-3xl font-semibold text-gray-800 mb-6">
          Página Não Encontrada
        </p>
        <p className="text-gray-600 text-lg mb-8">
          Ops! Parece que a página que você está procurando não existe.
        </p>
        <button
          onClick={handleGoHome}
          className="px-6 py-3 bg-indigo-700 text-white font-medium rounded-full 
                     shadow-lg hover:bg-indigo-800 transition duration-300 ease-in-out 
                     transform hover:scale-105 focus:outline-none focus:ring-2 
                     focus:ring-indigo-500 focus:ring-opacity-75"
        >
          Voltar para a Página Inicial
        </button>
      </div>
    </div>
  );
};

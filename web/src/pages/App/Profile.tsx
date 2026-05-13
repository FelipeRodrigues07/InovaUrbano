import React from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { MdEmail, MdPerson, MdCameraAlt, MdLogout } from 'react-icons/md';
import { AiOutlineLoading3Quarters } from 'react-icons/ai';

const Profile: React.FC = () => {
  const { userProfile, signOut, isLoadingUserStorageData } = useAuth();

  if (isLoadingUserStorageData) {
    return (
      <div className="flex h-screen items-center justify-center">
        <AiOutlineLoading3Quarters className="animate-spin text-blue-500" size={40} />
      </div>
    );
  }

  if (!userProfile) {
    return (
      <div className="p-5 text-center text-gray-500">
        Usuário não encontrado. Por favor, faça login novamente.
      </div>
    );
  }

  return (
    <div className="p-5 max-w-4xl mx-auto">
      <header className="mb-8 flex flex-col sm:flex-row justify-between items-center gap-4">
        <h1 className="text-xl sm:text-2xl font-bold text-gray-800">Meu Perfil</h1>
        <button 
          onClick={signOut}
          className="flex items-center gap-2 px-4 py-2 text-red-500 hover:bg-red-50 rounded-md transition font-semibold"
        >
          <MdLogout size={20} />
          Sair da conta
        </button>
      </header>
      
      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        {/* Banner com a cor do InovaUrbano */}
        <div className="h-32 bg-blue-500 w-full"></div>
        
        <div className="p-6 -mt-16 flex flex-col items-center sm:items-start">
          {/* Avatar com upload */}
          <div className="relative">
            <img 
              src={userProfile.profilePictureUrl || 'https://via.placeholder.com/150'} 
              alt={userProfile.name} 
              className="w-32 h-32 rounded-full border-4 border-white shadow-md object-cover bg-gray-100"
            />
            <button className="absolute bottom-1 right-1 bg-white p-2 rounded-full shadow-md hover:bg-gray-50 transition border border-gray-100">
              <MdCameraAlt size={18} className="text-gray-600" />
            </button>
          </div>

          <div className="mt-4 text-center sm:text-left">
            <h2 className="text-2xl font-bold text-gray-800">{userProfile.name}</h2>
            <p className="text-gray-400 text-sm font-medium uppercase tracking-tighter">ID: {userProfile.id}</p>
          </div>

          <hr className="w-full my-8 border-gray-100" />

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 w-full">
            <div className="flex items-center space-x-4 p-4 bg-gray-50 rounded-xl">
              <div className="bg-white p-2 rounded-lg shadow-sm text-blue-500">
                <MdPerson size={24} />
              </div>
              <div>
                <p className="text-[10px] text-gray-400 uppercase font-black tracking-widest">Nome Completo</p>
                <p className="text-gray-700 font-semibold">{userProfile.name}</p>
              </div>
            </div>

            <div className="flex items-center space-x-4 p-4 bg-gray-50 rounded-xl">
              <div className="bg-white p-2 rounded-lg shadow-sm text-blue-500">
                <MdEmail size={24} />
              </div>
              <div>
                <p className="text-[10px] text-gray-400 uppercase font-black tracking-widest">E-mail Cadastrado</p>
                <p className="text-gray-700 font-semibold">{userProfile.email}</p>
              </div>
            </div>
          </div>

          <div className="mt-10 flex gap-4 w-full sm:justify-end">
             <button className="flex-1 sm:flex-none px-8 py-3 bg-blue-500 text-white rounded-lg font-bold hover:bg-blue-600 transition shadow-lg shadow-blue-100 uppercase text-sm tracking-wide">
              Editar Dados
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Profile;
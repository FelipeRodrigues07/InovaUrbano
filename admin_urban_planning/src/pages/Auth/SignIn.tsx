import React, { useState } from 'react';
import { FiEye, FiEyeOff } from 'react-icons/fi'; 
import { useAuth } from '@/contexts/AuthContext';
import { useNavigate } from 'react-router-dom';

const SignIn: React.FC = () => {
  const [email, setEmail] = useState<string>('');
  const [password, setPassword] = useState<string>('');
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const { signIn } = useAuth();
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null); 
    try {
      await signIn(email, password); 
      console.log('Login bem-sucedido!');
      navigate('/dashboard', { replace: true }); 
    } catch (err: any) {
      console.error('Erro no login:', err);
     
      if (err.response && err.response.data && err.response.data.message) {
        setError(err.response.data.message); 
      } else {
        setError('Ocorreu um erro ao tentar fazer login. Verifique suas credenciais.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center"> 
      <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-sm"> 
        <h2 className="text-center text-3xl font-semibold mb-8 text-primary"> 
          InovaUrbano
        </h2>
        <form onSubmit={handleLogin} className="space-y-6">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700">
              Email
            </label>
            <input
              type="email"
              id="email"
              name="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            />
          </div>
          <div>
            <label htmlFor="password" className="block text-sm font-medium text-gray-700">
              Senha
            </label>
            <div className="relative mt-1"> 
              <input
                type={showPassword ? 'text' : 'password'} 
                id="password"
                name="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 pr-10 sm:text-sm" // Adiciona padding à direita para o ícone
              />
              <span
                className="absolute inset-y-0 right-0 pr-3 flex items-center cursor-pointer" 
                onClick={() => setShowPassword(!showPassword)} 
              >
                {showPassword ? (
                  <FiEye className="h-5 w-5 text-gray-400" /> 
                ) : (
                  <FiEyeOff  className="h-5 w-5 text-gray-400" /> 
                )}
              </span>
            </div>
          </div>
          {error && ( 
            <p className="text-red-600 text-sm text-center">{error}</p>
          )}
          <div>
            <button
              type="submit"
              disabled={loading} 
              className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium cursor-pointer text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              {loading ? 'Carregando...' : 'Fazer Login'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SignIn;
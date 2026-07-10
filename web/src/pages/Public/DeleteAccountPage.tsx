import React, { useState } from 'react';
import { FiEye, FiEyeOff } from 'react-icons/fi';
import { deleteAccountByCredentials } from '@/services/api/DeleteAccountService';

const DeleteAccountPage: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(null);

    try {
      const data = await deleteAccountByCredentials(email.trim(), password);
      setSuccess(
        data.message ||
          'Conta excluída. Dados pessoais foram removidos; relatos públicos permanecem anônimos.'
      );
      setEmail('');
      setPassword('');
    } catch (err: unknown) {
      const axiosErr = err as { response?: { data?: { message?: string } } };
      setError(
        axiosErr.response?.data?.message ||
          'Não foi possível excluir a conta. Verifique e-mail e senha.'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-50 px-4 py-10">
      <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-md">
        <h1 className="text-center text-3xl font-semibold mb-2 text-primary">
          Inova Urbano
        </h1>
        <h2 className="text-center text-xl font-medium mb-6 text-slate-800">
          Excluir conta
        </h2>

        <div className="mb-6 space-y-3 text-sm text-slate-600 leading-relaxed">
          <p>
            Você também pode excluir a conta pelo aplicativo: abra o perfil e
            toque em <strong>Excluir conta</strong>.
          </p>
          <p>
            Ao excluir, removemos seus dados pessoais (nome, e-mail, foto e
            senha). Relatos públicos permanecem no mapa de forma anônima, sem
            identificação.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-5">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700">
              Email da conta
            </label>
            <input
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoComplete="email"
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
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                autoComplete="current-password"
                className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm pr-10"
              />
              <button
                type="button"
                onClick={() => setShowPassword((v) => !v)}
                className="absolute inset-y-0 right-0 px-3 flex items-center text-gray-500"
                aria-label={showPassword ? 'Ocultar senha' : 'Mostrar senha'}
              >
                {showPassword ? <FiEyeOff /> : <FiEye />}
              </button>
            </div>
          </div>

          {error && (
            <p className="text-sm text-red-600" role="alert">
              {error}
            </p>
          )}
          {success && (
            <p className="text-sm text-green-700" role="status">
              {success}
            </p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full py-2.5 px-4 rounded-md text-white bg-red-600 hover:bg-red-700 disabled:opacity-60 font-medium"
          >
            {loading ? 'Excluindo...' : 'Excluir minha conta'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default DeleteAccountPage;

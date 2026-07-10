import { api } from '@/services/api/api';

export async function deleteAccountByCredentials(email: string, password: string) {
  const response = await api.post('/account/delete', { email, password });
  return response.data as { message: string };
}

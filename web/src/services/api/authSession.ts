import { api } from '@/services/api/api';
import { storageAuthToken } from '@/storage/storageAuthToken';
import { storageRefreshToken } from '@/storage/storageRefreshToken';

export interface AuthTokensResponse {
  token: string;
  refreshToken: string;
  expiresIn: number;
}

let refreshPromise: Promise<string | null> | null = null;

export function applyAccessToken(accessToken: string, expiresInSeconds: number): void {
  storageAuthToken.setAuthToken(accessToken);
  storageRefreshToken.setAccessExpiresAt(expiresInSeconds);
  api.defaults.headers.common.Authorization = `Bearer ${accessToken}`;
}

export function persistAuthTokens(data: AuthTokensResponse): void {
  applyAccessToken(data.token, data.expiresIn);
  storageRefreshToken.setRefreshToken(data.refreshToken);
}

export function clearAuthSession(): void {
  storageAuthToken.removeAuthToken();
  storageRefreshToken.removeRefreshToken();
  storageRefreshToken.removeAccessExpiresAt();
  delete api.defaults.headers.common.Authorization;
}

export async function refreshAccessToken(): Promise<string | null> {
  if (refreshPromise) {
    return refreshPromise;
  }

  refreshPromise = (async () => {
    const refreshToken = storageRefreshToken.getRefreshToken();
    if (!refreshToken) {
      return null;
    }

    try {
      const response = await api.post<AuthTokensResponse>('/refresh', {
        refreshToken,
      });
      persistAuthTokens(response.data);
      return response.data.token;
    } catch {
      clearAuthSession();
      return null;
    } finally {
      refreshPromise = null;
    }
  })();

  return refreshPromise;
}

export async function getValidAccessToken(): Promise<string | null> {
  const stored = storageAuthToken.getAuthToken();
  if (stored && !storageRefreshToken.isAccessTokenExpiringSoon()) {
    api.defaults.headers.common.Authorization = `Bearer ${stored}`;
    return stored;
  }
  return refreshAccessToken();
}

export async function logoutRemote(): Promise<void> {
  const refreshToken = storageRefreshToken.getRefreshToken();
  if (refreshToken) {
    try {
      await api.post('/logout', { refreshToken });
    } catch {
      // ignora falha remota
    }
  }
  clearAuthSession();
}

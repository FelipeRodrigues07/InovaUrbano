const REFRESH_TOKEN_KEY = 'refreshToken';
const ACCESS_EXPIRES_AT_KEY = 'accessTokenExpiresAtMs';

export const storageRefreshToken = {
  getRefreshToken: (): string | null => localStorage.getItem(REFRESH_TOKEN_KEY),

  setRefreshToken: (token: string): void => {
    localStorage.setItem(REFRESH_TOKEN_KEY, token);
  },

  removeRefreshToken: (): void => {
    localStorage.removeItem(REFRESH_TOKEN_KEY);
  },

  setAccessExpiresAt: (expiresInSeconds: number): void => {
    const expiresAt = Date.now() + expiresInSeconds * 1000;
    localStorage.setItem(ACCESS_EXPIRES_AT_KEY, String(expiresAt));
  },

  getAccessExpiresAt: (): number | null => {
    const raw = localStorage.getItem(ACCESS_EXPIRES_AT_KEY);
    return raw ? Number(raw) : null;
  },

  removeAccessExpiresAt: (): void => {
    localStorage.removeItem(ACCESS_EXPIRES_AT_KEY);
  },

  isAccessTokenExpiringSoon: (bufferMs = 60_000): boolean => {
    const expiresAt = storageRefreshToken.getAccessExpiresAt();
    if (expiresAt == null) return true;
    return Date.now() >= expiresAt - bufferMs;
  },
};

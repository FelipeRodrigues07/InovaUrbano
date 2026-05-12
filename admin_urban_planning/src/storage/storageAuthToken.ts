const AUTH_TOKEN_KEY = 'authToken';

export const storageAuthToken = {
  getAuthToken: (): string | null => {
    return localStorage.getItem(AUTH_TOKEN_KEY);
  },
  setAuthToken: (token: string): void => {
    localStorage.setItem(AUTH_TOKEN_KEY, token);
  },
  removeAuthToken: (): void => {
    localStorage.removeItem(AUTH_TOKEN_KEY);
  },

};
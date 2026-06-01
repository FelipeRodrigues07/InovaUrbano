import axios, { type InternalAxiosRequestConfig } from 'axios';
import {
  clearAuthSession,
  getValidAccessToken,
  refreshAccessToken,
} from '@/services/api/authSession';

const RAW_API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

if (!RAW_API_BASE_URL) {
  console.error('Environment variable API_BASE_URL is not set.');
}

const API_BASE_URL = RAW_API_BASE_URL ? RAW_API_BASE_URL.replace(/\/+$/, '') : '';

export const api = axios.create({
  baseURL: `${API_BASE_URL}/api`,
});

function isPublicAuthRoute(url?: string): boolean {
  if (!url) return false;
  return (
    url.includes('/authenticate') ||
    url.includes('/refresh') ||
    url.includes('/register')
  );
}

api.interceptors.request.use(async (config) => {
  if (!(config.data instanceof FormData)) {
    config.headers['Content-Type'] = 'application/json';
  }

  if (!isPublicAuthRoute(config.url)) {
    const token = await getValidAccessToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
  }

  return config;
});

interface RetryConfig extends InternalAxiosRequestConfig {
  _retry?: boolean;
}

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config as RetryConfig | undefined;
    const status = error.response?.status;

    if (
      status !== 401 ||
      !originalRequest ||
      originalRequest._retry ||
      isPublicAuthRoute(originalRequest.url)
    ) {
      return Promise.reject(error);
    }

    originalRequest._retry = true;
    const newToken = await refreshAccessToken();

    if (!newToken) {
      clearAuthSession();
      if (
        typeof window !== 'undefined' &&
        !window.location.pathname.startsWith('/login') &&
        !window.location.pathname.startsWith('/register')
      ) {
        window.location.href = '/login';
      }
      return Promise.reject(error);
    }

    originalRequest.headers.Authorization = `Bearer ${newToken}`;
    return api(originalRequest);
  }
);

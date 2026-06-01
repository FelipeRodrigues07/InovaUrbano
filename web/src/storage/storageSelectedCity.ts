import { DEFAULT_UF_ID } from '@/services/api/CitiesService';

const SELECTED_CITY_KEY = 'selectedCity';

export interface StoredSelectedCity {
  ufId: number;
  cityId: string;
}

export const storageSelectedCity = {
  get(): StoredSelectedCity | null {
    const raw = localStorage.getItem(SELECTED_CITY_KEY);
    if (!raw) return null;
    try {
      const parsed = JSON.parse(raw) as StoredSelectedCity;
      if (typeof parsed.ufId === 'number' && typeof parsed.cityId === 'string') {
        return parsed;
      }
    } catch {
      /* ignore */
    }
    return null;
  },

  set(data: StoredSelectedCity): void {
    localStorage.setItem(SELECTED_CITY_KEY, JSON.stringify(data));
  },

  getOrDefault(): StoredSelectedCity {
    return storageSelectedCity.get() ?? { ufId: DEFAULT_UF_ID, cityId: '' };
  },
};

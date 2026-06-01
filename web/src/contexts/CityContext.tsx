import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from 'react';
import type { ReactNode } from 'react';
import {
  CitiesService,
  DEFAULT_UF_ID,
  defaultCityIdForUf,
} from '@/services/api/CitiesService';
import type { CityDto, UfDto } from '@/services/api/CitiesService';
import { storageSelectedCity } from '@/storage/storageSelectedCity';

interface CityContextType {
  ufs: UfDto[];
  ufsLoading: boolean;
  ufId: number;
  setUfId: (id: number) => void;
  citiesList: CityDto[];
  citiesLoading: boolean;
  cityId: string;
  setCityId: (id: string) => void;
  selectedCity: CityDto | undefined;
  selectedUf: UfDto | undefined;
  resetToDefaultCity: () => void;
}

const CityContext = createContext<CityContextType | undefined>(undefined);

export const CityProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const stored = storageSelectedCity.getOrDefault();

  const [ufs, setUfs] = useState<UfDto[]>([]);
  const [ufsLoading, setUfsLoading] = useState(true);
  const [ufId, setUfIdState] = useState(stored.ufId);
  const [citiesList, setCitiesList] = useState<CityDto[]>([]);
  const [citiesLoading, setCitiesLoading] = useState(true);
  const [cityId, setCityIdState] = useState(stored.cityId);

  const persist = useCallback((nextUfId: number, nextCityId: string) => {
    storageSelectedCity.set({ ufId: nextUfId, cityId: nextCityId });
  }, []);

  const setUfId = useCallback((id: number) => {
    setUfIdState(id);
  }, []);

  const setCityId = useCallback(
    (id: string) => {
      setCityIdState(id);
      persist(ufId, id);
    },
    [ufId, persist]
  );

  const resetToDefaultCity = useCallback(() => {
    setUfIdState(DEFAULT_UF_ID);
  }, []);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const u = await CitiesService.getBrazilUfs();
        if (!cancelled) setUfs(u);
      } catch (e) {
        console.error(e);
      } finally {
        if (!cancelled) setUfsLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      setCitiesLoading(true);
      try {
        const rows = await CitiesService.getCitiesByUf(ufId);
        if (cancelled) return;

        setCitiesList(rows);

        setCityIdState((prev) => {
          const kept = prev && rows.some((c) => c.id === prev);
          const next = kept ? prev : defaultCityIdForUf(ufId, rows);
          persist(ufId, next);
          return next;
        });
      } catch (e) {
        console.error(e);
        if (!cancelled) {
          setCitiesList([]);
          setCityIdState('');
        }
      } finally {
        if (!cancelled) setCitiesLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [ufId, persist]);

  const selectedCity = citiesList.find((c) => c.id === cityId);
  const selectedUf = ufs.find((u) => u.id === ufId);

  return (
    <CityContext.Provider
      value={{
        ufs,
        ufsLoading,
        ufId,
        setUfId,
        citiesList,
        citiesLoading,
        cityId,
        setCityId,
        selectedCity,
        selectedUf,
        resetToDefaultCity,
      }}
    >
      {children}
    </CityContext.Provider>
  );
};

export const useCity = () => {
  const context = useContext(CityContext);
  if (context === undefined) {
    throw new Error('useCity must be used within a CityProvider');
  }
  return context;
};

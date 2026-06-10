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
import { useAuth } from '@/contexts/AuthContext';
import { isSuperAdmin } from '@/lib/userRoles';

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
  canSelectCity: boolean;
  isCityLocked: boolean;
}

const CityContext = createContext<CityContextType | undefined>(undefined);

export const CityProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const { userProfile, isLoadingUserStorageData } = useAuth();
  const stored = storageSelectedCity.getOrDefault();

  const canSelectCity = isSuperAdmin(userProfile?.role);
  const isCityLocked = !canSelectCity && !!userProfile?.ibgeId;

  const [ufs, setUfs] = useState<UfDto[]>([]);
  const [ufsLoading, setUfsLoading] = useState(true);
  const [ufId, setUfIdState] = useState(stored.ufId);
  const [citiesList, setCitiesList] = useState<CityDto[]>([]);
  const [citiesLoading, setCitiesLoading] = useState(true);
  const [cityId, setCityIdState] = useState(stored.cityId);
  const [tenantLocked, setTenantLocked] = useState(false);

  const persist = useCallback((nextUfId: number, nextCityId: string) => {
    if (!canSelectCity) return;
    storageSelectedCity.set({ ufId: nextUfId, cityId: nextCityId });
  }, [canSelectCity]);

  const setUfId = useCallback(
    (id: number) => {
      if (!canSelectCity) return;
      setUfIdState(id);
    },
    [canSelectCity]
  );

  const setCityId = useCallback(
    (id: string) => {
      if (!canSelectCity) return;
      setCityIdState(id);
      persist(ufId, id);
    },
    [canSelectCity, ufId, persist]
  );

  const resetToDefaultCity = useCallback(() => {
    if (!canSelectCity) return;
    setUfIdState(DEFAULT_UF_ID);
  }, [canSelectCity]);

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
    if (isLoadingUserStorageData) return;

    if (!userProfile || canSelectCity) {
      setTenantLocked(false);
      return;
    }

    if (!userProfile.ibgeId) return;

    let cancelled = false;
    (async () => {
      setCitiesLoading(true);
      setTenantLocked(true);
      try {
        const match = await CitiesService.findCityByIbgeId(userProfile.ibgeId!);
        if (cancelled || !match) return;

        setUfIdState(match.ufId);
        setCityIdState(match.city.id);
        const rows = await CitiesService.getCitiesByUf(match.ufId);
        if (!cancelled) setCitiesList(rows);
      } catch (e) {
        console.error(e);
      } finally {
        if (!cancelled) setCitiesLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [userProfile, isLoadingUserStorageData, canSelectCity]);

  useEffect(() => {
    if (tenantLocked || canSelectCity || isLoadingUserStorageData) return;

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
  }, [ufId, persist, tenantLocked, canSelectCity, isLoadingUserStorageData]);

  const selectedCity =
    citiesList.find((c) => c.id === cityId) ??
    (userProfile?.ibgeId
      ? {
          id: String(userProfile.ibgeId),
          name: userProfile.municipalityName ?? 'Município',
          latitude: 0,
          longitude: 0,
        }
      : undefined);

  const selectedUf =
    ufs.find((u) => u.id === ufId) ??
    (userProfile?.municipalityState
      ? {
          id: ufId,
          sigla: userProfile.municipalityState,
          nome: userProfile.municipalityState,
        }
      : undefined);

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
        canSelectCity,
        isCityLocked,
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

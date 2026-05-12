/**
 * Fontes públicas:
 * - UFs: https://brasilapi.com.br/api/ibge/uf/v1
 * - Municípios (nome + código IBGE + lat/long): repositório kelvins/Municipios-Brasileiros via CDN
 */

const BRASIL_API_UFS = 'https://brasilapi.com.br/api/ibge/uf/v1';
const MUNICIPIOS_JSON_URL =
  'https://cdn.jsdelivr.net/gh/kelvins/Municipios-Brasileiros@main/json/municipios.json';

export interface CityDto {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
}

export interface UfDto {
  id: number;
  sigla: string;
  nome: string;
}

interface MunicipioSource {
  codigo_ibge: number;
  nome: string;
  latitude: number;
  longitude: number;
  codigo_uf: number;
}

let municipiosCache: MunicipioSource[] | null = null;

async function loadAllMunicipios(): Promise<MunicipioSource[]> {
  if (municipiosCache) return municipiosCache;
  const res = await fetch(MUNICIPIOS_JSON_URL);
  if (!res.ok) {
    throw new Error(`Falha ao carregar municípios (${res.status})`);
  }
  municipiosCache = (await res.json()) as MunicipioSource[];
  return municipiosCache;
}

export const CitiesService = {
  async getBrazilUfs(): Promise<UfDto[]> {
    const res = await fetch(BRASIL_API_UFS);
    if (!res.ok) {
      throw new Error(`Falha ao carregar UFs (${res.status})`);
    }
    const data = (await res.json()) as { id: number; sigla: string; nome: string }[];
    return [...data].sort((a, b) => a.sigla.localeCompare(b.sigla, 'pt-BR'));
  },

  /** Municípios de uma UF, ordenados por nome (dataset nacional completo). */
  async getCitiesByUf(ufId: number): Promise<CityDto[]> {
    const all = await loadAllMunicipios();
    const filtered = all
      .filter((m) => m.codigo_uf === ufId)
      .sort((a, b) => a.nome.localeCompare(b.nome, 'pt-BR'));
    return filtered.map((m) => ({
      id: String(m.codigo_ibge),
      name: m.nome,
      latitude: m.latitude,
      longitude: m.longitude,
    }));
  },
};

/** Padrão: Mineiros (GO, IBGE 5213103); senão primeiro da lista ordenada. */
export function defaultCityIdForUf(ufId: number, cities: CityDto[]): string {
  if (!cities.length) return '';
  if (ufId === 52) {
    const mineiros = cities.find((c) => c.id === '5213103');
    if (mineiros) return mineiros.id;
  }
  return cities[0].id;
}

import { DEFAULT_UF_ID } from '@/services/api/CitiesService';
import { useCity } from '@/contexts/CityContext';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

interface CityFilterProps {
  cityTriggerClassName?: string;
  ufTriggerClassName?: string;
}

export function CityFilter({
  cityTriggerClassName = 'w-[10.5rem] max-w-[min(100%,10.5rem)] bg-white shadow-sm',
  ufTriggerClassName = 'w-[5.5rem] bg-white shadow-sm',
}: CityFilterProps) {
  const {
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
    canSelectCity,
    isCityLocked,
  } = useCity();

  if (isCityLocked || !canSelectCity) {
    return (
      <div className="inline-flex items-center gap-2 rounded-md border border-gray-200 bg-white px-3 py-1.5 text-sm shadow-sm">
        <span className="font-medium tabular-nums text-gray-700">
          {selectedUf?.sigla ?? '—'}
        </span>
        <span className="text-gray-400">·</span>
        <span className="font-medium text-gray-800">
          {selectedCity?.name ?? 'Município'}
        </span>
      </div>
    );
  }

  return (
    <>
      <Select
        value={String(ufId)}
        onValueChange={(v) => setUfId(Number(v))}
        disabled={ufsLoading && ufs.length === 0}
      >
        <SelectTrigger size="sm" className={ufTriggerClassName} aria-label="Estado">
          <SelectValue placeholder="UF">
            {ufsLoading && ufs.length === 0
              ? '…'
              : (selectedUf?.sigla ?? 'GO')}
          </SelectValue>
        </SelectTrigger>
        <SelectContent
          position="popper"
          sideOffset={4}
          className="z-[1100] max-h-52 w-[11rem] bg-white p-0"
        >
          {(ufs.length === 0
            ? [{ id: DEFAULT_UF_ID, sigla: 'GO', nome: 'Goiás' }]
            : ufs
          ).map((u) => (
            <SelectItem
              key={u.id}
              value={String(u.id)}
              className="py-1.5 pl-2 pr-7 text-sm"
            >
              <span className="font-medium tabular-nums">{u.sigla}</span>
              <span className="text-muted-foreground ml-1.5 truncate">
                {u.nome}
              </span>
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

      <Select
        value={cityId || undefined}
        onValueChange={setCityId}
        disabled={citiesLoading || citiesList.length === 0}
      >
        <SelectTrigger size="sm" className={cityTriggerClassName} aria-label="Município">
          <SelectValue placeholder="Município">
            {citiesLoading ? 'Carregando…' : (selectedCity?.name ?? 'Município')}
          </SelectValue>
        </SelectTrigger>
        <SelectContent
          position="popper"
          sideOffset={4}
          className="z-[1100] max-h-52 w-[var(--radix-select-trigger-width)] min-w-[10.5rem] bg-white p-0"
        >
          {citiesList.map((c) => (
            <SelectItem key={c.id} value={c.id} className="py-1.5 pl-2 pr-7 text-sm">
              {c.name}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </>
  );
}

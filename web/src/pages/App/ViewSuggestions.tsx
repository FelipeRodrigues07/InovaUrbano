import React, { useState, useEffect } from 'react';
import { format } from 'date-fns';
import { SuggestionsService } from '@/services/api/SuggestionsService';
import type { SuggestionsAdmModel, PaginationMeta } from '@/services/api/SuggestionsService';
import { DEFAULT_UF_ID } from '@/services/api/CitiesService';
import { useCity } from '@/contexts/CityContext';
import { DatePicker } from '@/components/ui/DatePicker';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useNavigate } from 'react-router-dom';

const suggestionTypes = [
  'Pendente',
  'Em análise',
  'Aprovadas',
  'Em andamento',
  'Concluídas',
  'Rejeitadas',
  'Todas',
];

const formatToBrazilianDate = (dateString: string) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return format(date, 'dd/MM/yyyy');
};

const statusBadgeClass: Record<string, string> = {
  Pendente: 'bg-amber-100 text-amber-800',
  'Em análise': 'bg-blue-100 text-blue-800',
  Aprovadas: 'bg-emerald-100 text-emerald-800',
  'Em andamento': 'bg-orange-100 text-orange-800',
  Concluídas: 'bg-green-100 text-green-800',
  Rejeitadas: 'bg-red-100 text-red-800',
};

const ViewSuggestions: React.FC = () => {
  const navigate = useNavigate();
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
    resetToDefaultCity,
  } = useCity();

  const [suggestions, setSuggestions] = useState<SuggestionsAdmModel[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isError, setIsError] = useState(false);
  const [numberSuggestion, setNumberSuggestion] = useState<number | undefined>(undefined);
  const [selectedType, setSelectedType] = useState<string>('');
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [meta, setMeta] = useState<PaginationMeta | null>(null);
  const pageSize = 10;

  const hasMore = meta != null && meta.current_page < meta.last_page;

  const fetchSuggestions = async (pageNumber: number, loadMore = false) => {
    if (!cityId) return;

    setIsLoading(true);
    setIsError(false);

    try {
      const result = await SuggestionsService.getSuggestions({
        numberSuggestion,
        status: selectedType === '' || selectedType === 'Todas' ? '' : selectedType,
        dateCalendar: selectedDate,
        ibgeId: parseInt(cityId, 10),
        pageNumber,
        pageSize,
      });

      setSuggestions(prev => (loadMore ? [...prev, ...result.data] : result.data));
      setMeta(result.meta);
    } catch {
      setIsError(true);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (citiesLoading || !cityId) return;

    let cancelled = false;

    (async () => {
      setIsLoading(true);
      setIsError(false);

      try {
        const result = await SuggestionsService.getSuggestions({
          numberSuggestion,
          status: selectedType === '' || selectedType === 'Todas' ? '' : selectedType,
          dateCalendar: selectedDate,
          ibgeId: parseInt(cityId, 10),
          pageNumber: 1,
          pageSize,
        });

        if (!cancelled) {
          setSuggestions(result.data);
          setMeta(result.meta);
        }
      } catch {
        if (!cancelled) setIsError(true);
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [selectedType, numberSuggestion, selectedDate, cityId, citiesLoading]);

  const loadMoreSuggestions = () => {
    if (!hasMore || isLoading) return;
    fetchSuggestions((meta?.current_page ?? 0) + 1, true);
  };

  const handleClearFilters = () => {
    setNumberSuggestion(undefined);
    setSelectedType('');
    setSelectedDate('');
    resetToDefaultCity();
  };

  return (
    <div className="p-4 sm:p-5 text-center">
      <h1 className="text-lg sm:text-xl font-bold mb-4">Visualizações de sugestões</h1>

      <div className="sticky top-16 z-40 -mx-4 sm:-mx-5 px-4 sm:px-5 py-2 mb-4 bg-background/95 backdrop-blur-sm border-b border-border">
        <div className="flex flex-wrap justify-center items-center gap-2">
          <Select
            value={String(ufId)}
            onValueChange={(v) => setUfId(Number(v))}
            disabled={ufsLoading && ufs.length === 0}
          >
            <SelectTrigger size="sm" className="w-[4.5rem] bg-white" aria-label="Estado">
              <SelectValue placeholder="UF">
                {ufsLoading && ufs.length === 0 ? '…' : (selectedUf?.sigla ?? 'GO')}
              </SelectValue>
            </SelectTrigger>
            <SelectContent position="popper" sideOffset={4} className="z-[1100] max-h-52 bg-white">
              {(ufs.length === 0
                ? [{ id: DEFAULT_UF_ID, sigla: 'GO', nome: 'Goiás' }]
                : ufs
              ).map((u) => (
                <SelectItem key={u.id} value={String(u.id)} className="text-sm">
                  <span className="font-medium">{u.sigla}</span>
                  <span className="text-muted-foreground ml-1.5 truncate">{u.nome}</span>
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          <Select
            value={cityId || undefined}
            onValueChange={setCityId}
            disabled={citiesLoading || citiesList.length === 0}
          >
            <SelectTrigger size="sm" className="w-[9.5rem] bg-white" aria-label="Município">
              <SelectValue placeholder="Município">
                {citiesLoading ? '…' : (selectedCity?.name ?? 'Município')}
              </SelectValue>
            </SelectTrigger>
            <SelectContent position="popper" sideOffset={4} className="z-[1100] max-h-52 min-w-[9.5rem] bg-white">
              {citiesList.map((c) => (
                <SelectItem key={c.id} value={c.id} className="text-sm">
                  {c.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          <Input
            type="number"
            placeholder="Nº sugestão"
            value={numberSuggestion ?? ''}
            onChange={(e) =>
              setNumberSuggestion(e.target.value ? Number(e.target.value) : undefined)
            }
            className="h-8 w-40 bg-white text-sm shadow-xs"
          />

          <Select
            value={selectedType || 'all'}
            onValueChange={(v) => setSelectedType(v === 'all' ? '' : v)}
          >
            <SelectTrigger size="sm" className="w-[8.5rem] bg-white" aria-label="Status">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent position="popper" sideOffset={4} className="z-[1100] bg-white">
              <SelectItem value="all" className="text-sm">Status</SelectItem>
              {suggestionTypes.map((type) => (
                <SelectItem key={type} value={type} className="text-sm">
                  {type}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          <DatePicker
            value={selectedDate}
            size="sm"
            onChange={setSelectedDate}
          />

          <Button
            type="button"
            variant="secondary"
            size="sm"
            onClick={handleClearFilters}
          >
            Limpar
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 px-2 sm:px-4">
        {isLoading && suggestions.length === 0 && (
          <p className="col-span-full text-center text-lg">Carregando...</p>
        )}
        {isError && (
          <p className="col-span-full text-center text-red-500">
            Erro ao carregar sugestões.
          </p>
        )}
        {suggestions.length === 0 && !isLoading && !isError && (
          <p className="col-span-full text-center text-gray-500">
            Nenhuma sugestão encontrada.
          </p>
        )}

        {suggestions.map((suggestion) => (
          <div
            key={suggestion.id}
            className="suggestion-card flex flex-col p-4 bg-white rounded-lg border border-gray-100 shadow-sm text-left"
          >
            <div className="flex items-start justify-between gap-2 mb-2 min-h-[2rem]">
              <div className="flex items-center min-w-0">
                <img
                  src={suggestion.profilePictureUrl || 'https://via.placeholder.com/32'}
                  alt="Profile"
                  className="w-8 h-8 rounded-full mr-2 object-cover shrink-0"
                />
                <span className="text-sm font-semibold text-gray-800 truncate">
                  {suggestion.userName}
                </span>
              </div>
              <span
                className={`shrink-0 text-xs font-medium px-2.5 py-0.5 rounded-full whitespace-nowrap ${
                  statusBadgeClass[suggestion.status] ?? 'bg-gray-100 text-gray-700'
                }`}
              >
                {suggestion.status}
              </span>
            </div>

            <span className="text-sm text-gray-500 mb-3">
              {formatToBrazilianDate(suggestion.createdAt)}
            </span>

            <img
              src={suggestion.suggestionImageUrl || 'https://via.placeholder.com/400x160'}
              alt="Suggestion"
              className="w-full h-36 object-cover rounded-md mb-3"
            />

            <p className="text-sm text-gray-700 mb-3 line-clamp-3 leading-relaxed">
              {suggestion.description}
            </p>

            <div className="text-sm text-gray-600 mb-4 space-y-1">
              <p>
                <span className="font-semibold text-gray-800">Problema:</span> {suggestion.type}
              </p>
              <p>
                <span className="font-semibold text-gray-800">Número:</span> {suggestion.number}
              </p>
            </div>

            <button
              onClick={() => {
                navigate('/posting-area', { state: { suggestionNumber: suggestion.number } });
              }}
              className="mt-auto w-full py-2 text-sm bg-gray-100 text-gray-800 rounded-md hover:bg-gray-200 transition"
            >
              Postar
            </button>
          </div>
        ))}
      </div>
      {hasMore && (
        <div className="mt-5">
          {isLoading ? (
            <p className="text-center text-gray-500">Carregando mais...</p>
          ) : (
            <button
              onClick={loadMoreSuggestions}
              className="px-5 py-2 bg-blue-400 text-white rounded-md hover:bg-blue-700 transition"
            >
              Carregar Mais
            </button>
          )}
        </div>
      )}
    </div>
  );
};

export default ViewSuggestions;
import React, { useState, useEffect } from 'react';
import { format } from 'date-fns';
import { SuggestionsService } from '@/services/api/SuggestionsService';
import type { SuggestionsAdmModel, GetSuggestionsParams } from '@/services/api/SuggestionsService';
import { DatePicker } from '@/components/ui/DatePicker';
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

const ViewSuggestions: React.FC = () => {
  const navigate = useNavigate();
  const [suggestions, setSuggestions] = useState<SuggestionsAdmModel[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isError, setIsError] = useState(false);
  const [numberSuggestion, setNumberSuggestion] = useState<number | undefined>(undefined);
  const [selectedType, setSelectedType] = useState<string>('');
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [pageNumber, setPageNumber] = useState(1);
  const pageSize = 10;

  const getSuggestions = async (loadMore = false) => {
    setIsLoading(true);
    setIsError(false);

    try {
      const params: GetSuggestionsParams = {
        numberSuggestion,
        status: selectedType === '' ? '' : selectedType,
        dateCalendar: selectedDate,
        pageNumber: loadMore ? pageNumber + 1 : 1,
        pageSize,
      };

      const newSuggestions = await SuggestionsService.getSuggestions(params);

      setSuggestions(prevSuggestions =>
        loadMore ? [...prevSuggestions, ...newSuggestions] : newSuggestions
      );

      if (loadMore) {
        setPageNumber(prevPageNumber => prevPageNumber + 1);
      } else {
        setPageNumber(2);
      }
    } catch (error) {
      setIsError(true);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    getSuggestions(false);
  }, [selectedType, numberSuggestion, selectedDate]);

  const handleClearFilters = () => {
    setNumberSuggestion(undefined);
    setSelectedType('');
    setSelectedDate('');
    getSuggestions(false);
  };

  return (
    <div className="p-5 text-center">
      <h1 className="text-xl sm:text-2xl font-bold mb-10">Visualizações de sugestões</h1>

      <div className="flex flex-wrap justify-center gap-5 mb-10">
        <input
          type="number"
          placeholder="Número da Sugestão"
          value={numberSuggestion ?? ''}
          onChange={(e) =>
            setNumberSuggestion(e.target.value ? Number(e.target.value) : undefined)
          }
          onBlur={() => getSuggestions(false)}
          className="p-2 w-48 border border-gray-300 rounded-md"
        />

        <select
          value={selectedType}
          onChange={(e) => {
            setSelectedType(e.target.value);
          }}
          className="p-2 w-48 border border-gray-300 rounded-md"
        >
          <option value="">Status</option>
          {suggestionTypes.map((type) => (
            <option key={type} value={type}>
              {type}
            </option>
          ))}
        </select>

        <DatePicker
          value={selectedDate}
          onChange={(date) => {
            setSelectedDate(date)
          }}
        />

        <button
          onClick={handleClearFilters}
          className="p-2 bg-gray-500 text-white rounded-md hover:bg-gray-600 transition"
        >
          Limpar Filtros
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5 px-4">
        {isLoading && suggestions.length === 0 && (
          <p className="col-span-full text-center text-lg">Carregando...</p>
        )}
        {isError && (
          <p className="col-span-full text-center text-red-500">
            Erro ao carregar postagens.
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
            className="suggestion-card flex flex-col p-4 bg-white rounded-lg shadow-md"
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center">
                <img
                  src={suggestion.profilePictureUrl || 'https://via.placeholder.com/35'}
                  alt="Profile"
                  className="w-9 h-9 rounded-full mr-2 object-cover"
                />
                <span className="font-bold text-gray-800">{suggestion.userName}</span>
              </div>
              <span className="text-sm text-gray-500">
                {formatToBrazilianDate(suggestion.createdAt)}
              </span>
            </div>

            <img
              src={suggestion.suggestionImageUrl || 'https://via.placeholder.com/400x200'}
              alt="Suggestion"
              className="w-full h-48 object-cover rounded-md mb-4"
            />

            <p className="text-sm text-gray-700 mb-2">{suggestion.description}</p>
            <p className="text-sm mb-1">
              <strong className="font-semibold">Problema:</strong> {suggestion.type}
            </p>
            <p className="text-sm mb-1">
              <strong className="font-semibold">Status:</strong> {suggestion.status}
            </p>
            <p className="text-sm mb-4">
              <strong className="font-semibold">Número:</strong> {suggestion.number}
            </p>

            <button
              onClick={() => {
                navigate('/posting-area', { state: { suggestionNumber: suggestion.number } });
              }}
              className="mt-auto w-full p-2 bg-gray-200 text-black rounded-md hover:bg-gray-300 transition"
            >
              Postar
            </button>
          </div>
        ))}
      </div>
      {suggestions.length > 0 && (
        <div className="mt-5">
          {isLoading ? (
            <p className="text-center text-gray-500">Carregando mais...</p>
          ) : (
            <button
              onClick={() => getSuggestions(true)}
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
import React, { useState, useEffect } from 'react';
import { format } from 'date-fns';
import { PostingService } from '@/services/api/PostingService';
import type { PostingAdmModel, GetPostingParams } from '@/services/api/PostingService';
import { DatePicker } from '@/components/ui/DatePicker';

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

const ViewPostings: React.FC = () => {
  const [postings, setPostings] = useState<PostingAdmModel[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isError, setIsError] = useState(false);
  const [numberSuggestion, setNumberSuggestion] = useState<number | undefined>(undefined);
  const [selectedType, setSelectedType] = useState<string>('');
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [pageNumber, setPageNumber] = useState(1);
  const pageSize = 10;

  const getPostings = async (loadMore = false) => {
    setIsLoading(true);
    setIsError(false);

    try {
      const params: GetPostingParams = {
        numberSuggestion,
        status: selectedType === '' ? '' : selectedType,
        dateCalendar: selectedDate,
        pageNumber: loadMore ? pageNumber + 1 : 1,
        pageSize,
      };

      const newPostings = await PostingService.getPosting(params);

      setPostings(prevPosting =>
        loadMore ? [...prevPosting, ...newPostings] : newPostings
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
    getPostings(false);
  }, [selectedType, numberSuggestion, selectedDate]);

  const handleClearFilters = () => {
    setNumberSuggestion(undefined);
    setSelectedType('');
    setSelectedDate('');
    getPostings(false);
  };

  return (
    <div className="p-5 text-center">
      <h1 className="text-xl sm:text-2xl font-bold mb-10">Visualizações de postagens</h1>
      <div className="flex flex-wrap justify-center gap-5 mb-10">
        <input
          type="number"
          placeholder="Número da Postagem"
          value={numberSuggestion ?? ''}
          onChange={(e) =>
            setNumberSuggestion(e.target.value ? Number(e.target.value) : undefined)
          }
          onBlur={() => getPostings(false)}
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
        {isLoading && postings.length === 0 && (
          <p className="col-span-full text-center text-lg">Carregando...</p>
        )}
        {isError && (
          <p className="col-span-full text-center text-red-500">
            Erro ao carregar postagens.
          </p>
        )}
        {postings.length === 0 && !isLoading && !isError && (
          <p className="col-span-full text-center text-gray-500">
            Nenhuma sugestão encontrada.
          </p>
        )}
        {postings.map((posting) => (
          <div
            key={posting.id}
            className="suggestion-card flex flex-col p-4 bg-white rounded-lg shadow-md"
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center">
                <img
                  src={posting.profilePictureUrl || 'https://via.placeholder.com/35'}
                  alt="Profile"
                  className="w-9 h-9 rounded-full mr-2 object-cover"
                />
                <span className="font-bold text-gray-800">{posting.userName}</span>
              </div>
              <span className="text-sm text-gray-500">
                {formatToBrazilianDate(posting.createdAt)}
              </span>
            </div>

            <img
              src={posting.postImageUrl || 'https://via.placeholder.com/400x200'}
              alt="posting"
              className="w-full h-48 object-cover rounded-md mb-4"
            />
            <p className="text-sm mb-1">
              <strong className="font-semibold">Motivo:</strong> {posting.title}
            </p>
            <p className="text-sm text-gray-700 mb-2">{posting.description}</p>
            <p className="text-sm mb-4">
              <strong className="font-semibold">Número da Sugestão:</strong> {posting.numberSuggestion}
            </p>

            <button
              onClick={() => {
              }}
              className="mt-auto w-full p-2 bg-gray-200 text-black rounded-md hover:bg-gray-300 transition"
            >
              Postar
            </button>
          </div>
        ))}
      </div>
      {postings.length > 0 && (
        <div className="mt-5">
          {isLoading ? (
            <p className="text-center text-gray-500">Carregando mais...</p>
          ) : (
            <button
              onClick={() => getPostings(true)}
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

export default ViewPostings;
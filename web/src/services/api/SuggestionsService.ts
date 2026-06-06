import { api } from '@/services/api/api';

export interface PaginationMeta {
    current_page: number;
    per_page: number;
    total: number;
    last_page: number;
}

export interface PaginatedResponse<T> {
    data: T[];
    meta: PaginationMeta;
}

export interface GetSuggestionsParams {
    numberSuggestion?: number;
    status?: string;
    dateCalendar?: string;
    ibgeId?: number;
    pageNumber?: number;
    pageSize?: number;
}

export interface GetSuggestionsByAreaParams {
    latMin: number;
    latMax: number;
    lonMin: number;
    lonMax: number;
    status: string;
}

export interface SuggestionsAdmModel {
    id: string;
    userName: string;
    profilePictureUrl: string;
    createdAt: string;
    suggestionImageUrl?: string;
    description: string;
    type: string;
    status: string;
    number: number;
}

export interface GetAllSuggestionsAreaModel {
    id: string;
    type: string;
    description: string;
    latitude: number;
    longitude: number;
    status: string;
    suggestionImageUrl?: string;
    userId: string;
    createdAt: string;
}

export const SuggestionsService = {
    getSuggestions: async ({
        numberSuggestion = 0,
        status = '',
        dateCalendar = '',
        ibgeId,
        pageNumber = 1,
        pageSize = 10,
    }: GetSuggestionsParams): Promise<PaginatedResponse<SuggestionsAdmModel>> => {
        try {
            const params: Record<string, string | number> = {
                NumberSuggestion: numberSuggestion,
                Status: status,
                DateCalendar: dateCalendar,
                pageNumber,
                pageSize,
            };

            if (ibgeId != null && ibgeId > 0) {
                params.IbgeId = ibgeId;
            }

            const response = await api.get<PaginatedResponse<SuggestionsAdmModel>>(
                '/suggestions/adm',
                { params },
            );
            return response.data;
        } catch (error) {
            console.error('Falha na requisição:', error);
            throw error;
        }
    },

    getSuggestionsByArea: async ({
        latMin,
        latMax,
        lonMin,
        lonMax,
        status,
    }: GetSuggestionsByAreaParams): Promise<GetAllSuggestionsAreaModel[]> => {
        try {
            const response = await api.get('/suggestions/area', {
                params: {
                    latMin,
                    latMax,
                    lonMin,
                    lonMax,
                    status,
                },
            });

            return response.data;
        } catch (error) {
            console.error('Erro ao buscar sugestões por área:', error);
            throw error;
        }
    },
};

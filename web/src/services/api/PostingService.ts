import { api } from '@/services/api/api';
import type { PaginatedResponse, PaginationMeta } from '@/services/api/SuggestionsService';

export type { PaginatedResponse, PaginationMeta };

export interface GetPostingParams {
    numberSuggestion?: number;
    status?: string;
    dateCalendar?: string;
    ibgeId?: number;
    pageNumber?: number;
    pageSize?: number;
}

export interface PostingAdmModel {
    id: string;
    userId: string;
    userName: string;
    profilePictureUrl: string;
    createdAt: string;
    postImageUrl?: string;
    description: string;
    title: string;
    status: string;
    number: number;
    numberSuggestion: number;
}

export const PostingService = {
    getPosting: async ({
        numberSuggestion = 0,
        status = '',
        dateCalendar = '',
        ibgeId,
        pageNumber = 1,
        pageSize = 10,
    }: GetPostingParams): Promise<PaginatedResponse<PostingAdmModel>> => {
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

            const response = await api.get<PaginatedResponse<PostingAdmModel>>('/posts/adm', {
                params,
            });
            return response.data;
        } catch (error) {
            console.error('Falha na requisição:', error);
            throw error;
        }
    },
};

import { api } from '@/services/api/api';

export interface GetPostingParams {
    numberSuggestion?: number;
    status?: string;
    dateCalendar?: string;
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
        pageNumber = 1,
        pageSize = 10,
    }: GetPostingParams): Promise<PostingAdmModel[]> => {
        try {
            const response = await api.get('/posts/adm', {
                params: {
                    NumberSuggestion: numberSuggestion,
                    Status: status,
                    DateCalendar: dateCalendar,
                    pageNumber,
                    pageSize,
                },
            });
            return response.data;
        } catch (error) {
            console.error('Falha na requisição:', error);
            throw error;
        }
    },
};
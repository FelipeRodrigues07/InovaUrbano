import { api } from '@/services/api/api';

export type AnalyticsGroupBy = 'day' | 'month' | 'year';

export interface GetAnalyticsParams {
    status?: string;
    ibgeId?: number;
    dateFrom?: string;
    dateTo?: string;
    groupBy?: AnalyticsGroupBy;
}

export interface AnalyticsSummary {
    total: number;
}

export interface TimeSeriesPoint {
    period: string;
    count: number;
}

export interface CountByLabel {
    label: string;
    count: number;
}

export interface SuggestionsAnalyticsResponse {
    summary: AnalyticsSummary;
    timeSeries: TimeSeriesPoint[];
    byStatus: CountByLabel[];
    byType: CountByLabel[];
}

export const AnalyticsService = {
    getSuggestionsAnalytics: async ({
        status = '',
        ibgeId,
        dateFrom = '',
        dateTo = '',
        groupBy = 'month',
    }: GetAnalyticsParams): Promise<SuggestionsAnalyticsResponse> => {
        const params: Record<string, string | number> = {
            Status: status,
            DateFrom: dateFrom,
            DateTo: dateTo,
            GroupBy: groupBy,
        };

        if (ibgeId != null && ibgeId > 0) {
            params.IbgeId = ibgeId;
        }

        const response = await api.get<SuggestionsAnalyticsResponse>(
            '/suggestions/analytics',
            { params },
        );

        return response.data;
    },
};

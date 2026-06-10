import { useEffect, useMemo, useState } from 'react';
import { format, parseISO, subMonths } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { Bar, BarChart, CartesianGrid, Cell, Pie, PieChart, XAxis, YAxis } from 'recharts';
import { useCity } from '@/contexts/CityContext';
import { CityFilter } from '@/components/ui/CityFilter';
import {
    AnalyticsService,
    type AnalyticsGroupBy,
    type SuggestionsAnalyticsResponse,
} from '@/services/api/AnalyticsService';
import { DatePicker } from '@/components/ui/DatePicker';
import { Button } from '@/components/ui/button';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import {
    Card,
    CardAction,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from '@/components/ui/card';
import {
    ChartContainer,
    ChartTooltip,
    ChartTooltipContent,
    type ChartConfig,
} from '@/components/ui/chart';

const statusOptions = [
    'Pendente',
    'Em análise',
    'Aprovadas',
    'Em andamento',
    'Concluídas',
    'Rejeitadas',
    'Todas',
];

const groupByOptions: { value: AnalyticsGroupBy; label: string }[] = [
    { value: 'day', label: 'Diário' },
    { value: 'month', label: 'Mensal' },
    { value: 'year', label: 'Anual' },
];

const statusColors: Record<string, string> = {
    Pendente: '#f59e0b',
    'Em análise': '#2196F3',
    Aprovadas: '#10b981',
    'Em andamento': '#ea580c',
    Concluídas: '#16a34a',
    Rejeitadas: '#dc2626',
};

const typeColors: Record<string, string> = {
    Trânsito: '#dc2626',
    Limpeza: '#16a34a',
    Infraestrutura: '#2563eb',
    Acessibilidade: '#eab308',
    Segurança: '#ea580c',
    'Saúde Pública': '#f472b6',
};

const chartFallbackColor = '#6b7280';

function getStatusColor(status: string): string {
    return statusColors[status] ?? chartFallbackColor;
}

function getTypeColor(type: string): string {
    return typeColors[type] ?? chartFallbackColor;
}

const timeSeriesConfig = {
    count: {
        label: 'Sugestões',
        color: 'var(--primary)',
    },
} satisfies ChartConfig;

function formatPeriod(period: string, groupBy: AnalyticsGroupBy): string {
    if (groupBy === 'year') return period;

    if (groupBy === 'month') {
        const [year, month] = period.split('-');
        return `${month}/${year}`;
    }

    try {
        return format(parseISO(period), 'dd/MM/yyyy', { locale: ptBR });
    } catch {
        return period;
    }
}

function defaultDateFrom() {
    return format(subMonths(new Date(), 12), 'yyyy-MM-dd');
}

function defaultDateTo() {
    return format(new Date(), 'yyyy-MM-dd');
}

export default function Analytics() {
    const { cityId, citiesLoading, resetToDefaultCity, canSelectCity } = useCity();

    const [selectedStatus, setSelectedStatus] = useState('');
    const [dateFrom, setDateFrom] = useState(defaultDateFrom);
    const [dateTo, setDateTo] = useState(defaultDateTo);
    const [groupBy, setGroupBy] = useState<AnalyticsGroupBy>('month');
    const [data, setData] = useState<SuggestionsAnalyticsResponse | null>(null);
    const [isLoading, setIsLoading] = useState(false);
    const [isError, setIsError] = useState(false);

    useEffect(() => {
        if (citiesLoading || !cityId) return;

        let cancelled = false;

        (async () => {
            setIsLoading(true);
            setIsError(false);

            try {
                const result = await AnalyticsService.getSuggestionsAnalytics({
                    status: selectedStatus === '' || selectedStatus === 'Todas' ? '' : selectedStatus,
                    ibgeId: parseInt(cityId, 10),
                    dateFrom,
                    dateTo,
                    groupBy,
                });

                if (!cancelled) setData(result);
            } catch {
                if (!cancelled) setIsError(true);
            } finally {
                if (!cancelled) setIsLoading(false);
            }
        })();

        return () => {
            cancelled = true;
        };
    }, [selectedStatus, dateFrom, dateTo, groupBy, cityId, citiesLoading]);

    const timeSeriesChartData = useMemo(
        () =>
            (data?.timeSeries ?? []).map((item) => ({
                ...item,
                label: formatPeriod(item.period, groupBy),
            })),
        [data?.timeSeries, groupBy],
    );

    const statusChartConfig = useMemo(() => {
        const config: ChartConfig = { count: { label: 'Quantidade' } };
        (data?.byStatus ?? []).forEach((item) => {
            config[item.label] = {
                label: item.label,
                color: getStatusColor(item.label),
            };
        });
        return config;
    }, [data?.byStatus]);

    const typeChartConfig = useMemo(() => {
        const config: ChartConfig = { count: { label: 'Quantidade' } };
        (data?.byType ?? []).forEach((item) => {
            config[item.label] = {
                label: item.label,
                color: getTypeColor(item.label),
            };
        });
        return config;
    }, [data?.byType]);

    const pendingCount =
        data?.byStatus.find((item) => item.label === 'Pendente')?.count ?? 0;
    const completedCount =
        data?.byStatus.find((item) => item.label === 'Concluídas')?.count ?? 0;

    const handleClearFilters = () => {
        setSelectedStatus('');
        setDateFrom(defaultDateFrom());
        setDateTo(defaultDateTo());
        setGroupBy('month');
        if (canSelectCity) resetToDefaultCity();
    };

    return (
        <div className="p-4 sm:p-5 text-center">
            <h1 className="text-lg sm:text-xl font-bold mb-2">Análise de sugestões</h1>
            <p className="text-sm text-muted-foreground mb-4">
                Gráficos e indicadores com base nos filtros selecionados.
            </p>

            <div className="sticky top-16 z-40 -mx-4 sm:-mx-5 px-4 sm:px-5 py-2 mb-4 bg-background/95 backdrop-blur-sm border-b border-border">
                <div className="flex flex-wrap justify-center items-center gap-2">
                    <CityFilter
                        ufTriggerClassName="w-[4.5rem] bg-white"
                        cityTriggerClassName="w-[9.5rem] bg-white"
                    />

                    <Select
                        value={selectedStatus || 'all'}
                        onValueChange={(v) => setSelectedStatus(v === 'all' ? '' : v)}
                    >
                        <SelectTrigger size="sm" className="w-[8.5rem] bg-white" aria-label="Status">
                            <SelectValue placeholder="Status" />
                        </SelectTrigger>
                        <SelectContent position="popper" sideOffset={4} className="z-[1100] bg-white">
                            <SelectItem value="all" className="text-sm">Status</SelectItem>
                            {statusOptions.map((status) => (
                                <SelectItem key={status} value={status} className="text-sm">
                                    {status}
                                </SelectItem>
                            ))}
                        </SelectContent>
                    </Select>

                    <DatePicker
                        value={dateFrom}
                        onChange={setDateFrom}
                        size="sm"
                        placeholder="De"
                        className="w-32"
                    />

                    <DatePicker
                        value={dateTo}
                        onChange={setDateTo}
                        size="sm"
                        placeholder="Até"
                        className="w-32"
                    />

                    <Button type="button" variant="secondary" size="sm" onClick={handleClearFilters}>
                        Limpar
                    </Button>
                </div>
            </div>

            {isError && (
                <p className="text-red-500 text-sm mb-4">Erro ao carregar análise.</p>
            )}

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-left">
                <Card>
                    <CardHeader className="pb-2">
                        <CardDescription>Total no período</CardDescription>
                        <CardTitle className="text-3xl tabular-nums">
                            {isLoading ? '…' : (data?.summary.total ?? 0)}
                        </CardTitle>
                    </CardHeader>
                </Card>
                <Card>
                    <CardHeader className="pb-2">
                        <CardDescription>Pendentes</CardDescription>
                        <CardTitle className="text-3xl tabular-nums text-amber-600">
                            {isLoading ? '…' : pendingCount}
                        </CardTitle>
                    </CardHeader>
                </Card>
                <Card>
                    <CardHeader className="pb-2">
                        <CardDescription>Concluídas</CardDescription>
                        <CardTitle className="text-3xl tabular-nums text-emerald-600">
                            {isLoading ? '…' : completedCount}
                        </CardTitle>
                    </CardHeader>
                </Card>
            </div>

            <div className="grid grid-cols-1 xl:grid-cols-2 gap-4 mt-4 text-left">
                <Card>
                    <CardHeader>
                        <CardTitle>Evolução no tempo</CardTitle>
                        <CardAction>
                            <Select
                                value={groupBy}
                                onValueChange={(v) => setGroupBy(v as AnalyticsGroupBy)}
                            >
                                <SelectTrigger
                                    size="sm"
                                    className="w-[7.5rem] bg-white"
                                    aria-label="Agrupar gráfico por"
                                >
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent position="popper" sideOffset={4} className="z-[1100] bg-white">
                                    {groupByOptions.map((option) => (
                                        <SelectItem key={option.value} value={option.value} className="text-sm">
                                            {option.label}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </CardAction>
                        <CardDescription>
                            {format(new Date(dateFrom), 'dd/MM/yyyy')} até {format(new Date(dateTo), 'dd/MM/yyyy')}
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        {timeSeriesChartData.length === 0 && !isLoading ? (
                            <p className="text-sm text-muted-foreground text-center py-16">
                                Nenhum dado no período selecionado.
                            </p>
                        ) : (
                            <ChartContainer config={timeSeriesConfig} className="h-[280px] w-full aspect-auto">
                                <BarChart data={timeSeriesChartData} margin={{ left: 0, right: 8 }}>
                                    <CartesianGrid vertical={false} />
                                    <XAxis
                                        dataKey="label"
                                        tickLine={false}
                                        axisLine={false}
                                        tickMargin={8}
                                        interval="preserveStartEnd"
                                    />
                                    <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={32} />
                                    <ChartTooltip content={<ChartTooltipContent />} />
                                    <Bar dataKey="count" fill="var(--color-count)" radius={4} />
                                </BarChart>
                            </ChartContainer>
                        )}
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle>Por status</CardTitle>
                        <CardDescription>Distribuição das sugestões filtradas</CardDescription>
                    </CardHeader>
                    <CardContent>
                        {(data?.byStatus.length ?? 0) === 0 && !isLoading ? (
                            <p className="text-sm text-muted-foreground text-center py-16">
                                Nenhum dado no período selecionado.
                            </p>
                        ) : (
                            <ChartContainer config={statusChartConfig} className="h-[280px] w-full aspect-auto">
                                <BarChart
                                    data={data?.byStatus ?? []}
                                    layout="vertical"
                                    margin={{ left: 8, right: 16 }}
                                >
                                    <CartesianGrid horizontal={false} />
                                    <YAxis
                                        dataKey="label"
                                        type="category"
                                        tickLine={false}
                                        axisLine={false}
                                        width={96}
                                        tickMargin={8}
                                    />
                                    <XAxis type="number" allowDecimals={false} tickLine={false} axisLine={false} />
                                    <ChartTooltip content={<ChartTooltipContent />} />
                                    <Bar dataKey="count" radius={4}>
                                        {(data?.byStatus ?? []).map((item) => (
                                            <Cell
                                                key={item.label}
                                                fill={getStatusColor(item.label)}
                                            />
                                        ))}
                                    </Bar>
                                </BarChart>
                            </ChartContainer>
                        )}
                    </CardContent>
                </Card>

                <Card className="xl:col-span-2">
                    <CardHeader>
                        <CardTitle>Por tipo de problema</CardTitle>
                        <CardDescription>Trânsito, limpeza, infraestrutura e outros</CardDescription>
                    </CardHeader>
                    <CardContent>
                        {(data?.byType.length ?? 0) === 0 && !isLoading ? (
                            <p className="text-sm text-muted-foreground text-center py-16">
                                Nenhum dado no período selecionado.
                            </p>
                        ) : (
                            <ChartContainer config={typeChartConfig} className="mx-auto h-[300px] w-full max-w-md aspect-auto">
                                <PieChart>
                                    <ChartTooltip content={<ChartTooltipContent hideLabel />} />
                                    <Pie
                                        data={data?.byType ?? []}
                                        dataKey="count"
                                        nameKey="label"
                                        cx="50%"
                                        cy="50%"
                                        innerRadius={60}
                                        outerRadius={100}
                                        paddingAngle={2}
                                    >
                                        {(data?.byType ?? []).map((item) => (
                                            <Cell
                                                key={item.label}
                                                fill={getTypeColor(item.label)}
                                            />
                                        ))}
                                    </Pie>
                                </PieChart>
                            </ChartContainer>
                        )}
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}

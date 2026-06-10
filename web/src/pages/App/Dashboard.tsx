import { useEffect, useRef, useState } from 'react';
import { MapContainer, TileLayer, Marker, useMapEvents, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

import { SuggestionsService } from '@/services/api/SuggestionsService';
import { useCity } from '@/contexts/CityContext';
import { CityFilter } from '@/components/ui/CityFilter';

import type { GetAllSuggestionsAreaModel } from '@/services/api/SuggestionsService';

// Corrige ícone padrão do Leaflet
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
    iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

/** Goiás — alinhado ao uso anterior do dashboard */

const statusList = [
    'Todas',
    'Em análise',
    'Aprovadas',
    'Em andamento',
    'Concluídas',
];

// Recentraliza só quando lat/lng mudam (ex.: outro município). Objetos inline no JSX
// gerariam nova referência a cada render e o mapa “puxava” de volta ao centro.
function ChangeView({ lat, lng }: { lat: number; lng: number }) {
    const map = useMap();
    useEffect(() => {
        map.setView([lat, lng], map.getZoom());
    }, [lat, lng, map]);
    return null;
}

export default function SuggestionsMapPage() {
    const { cityId, selectedCity, citiesLoading } = useCity();

    const [status, setStatus] = useState('Todas');
    const [suggestions, setSuggestions] = useState<GetAllSuggestionsAreaModel[]>([]);
    const [loading, setLoading] = useState(false);
    const [selectedSuggestion, setSelectedSuggestion] = useState<GetAllSuggestionsAreaModel | null>(null);
    const mapRef = useRef<L.Map | null>(null)

    const debounceRef = useRef<NodeJS.Timeout | null>(null);

    const mapCenter = selectedCity
        ? { lat: selectedCity.latitude, lng: selectedCity.longitude }
        : { lat: -15.78, lng: -47.93 };

    const fetchSuggestions = async (
        center: { lat: number; lng: number },
        zoom: number
    ) => {
        setLoading(true);
        const mapHeight = 430;
        const mapWidth = window.innerWidth;

        const latDelta = (180 / Math.pow(2, zoom)) * (mapHeight / 256);
        const lonDelta = (180 / Math.pow(2, zoom)) * (mapWidth / 256);

        try {
            const data = await SuggestionsService.getSuggestionsByArea({
                latMin: center.lat - latDelta,
                latMax: center.lat + latDelta,
                lonMin: center.lng - lonDelta,
                lonMax: center.lng + lonDelta,
                status,
            });
            setSuggestions(data);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    function MapEvents() {
        useMapEvents({
            moveend(e) {
                if (debounceRef.current) clearTimeout(debounceRef.current);
                debounceRef.current = setTimeout(() => {
                    const center = e.target.getCenter();
                    const zoom = e.target.getZoom();
                    fetchSuggestions(center, zoom);
                }, 300);
            },
        });
        return null;
    }

    useEffect(() => {
        if (!selectedCity) return;
        if (mapRef.current) {
            const center = mapRef.current.getCenter();
            const zoom = mapRef.current.getZoom();
            fetchSuggestions(center, zoom);
        } else {
            fetchSuggestions({ lat: selectedCity.latitude, lng: selectedCity.longitude }, 14);
        }
    }, [cityId, status, selectedCity]);

    const getMarkerColor = (type: string) => {
        switch (type) {
            case 'Trânsito': return '#dc2626';
            case 'Limpeza': return '#16a34a';
            case 'Infraestrutura': return '#2563eb';
            case 'Acessibilidade': return '#eab308';
            case 'Segurança': return '#ea580c';
            case 'Saúde Pública': return '#f472b6';
            default: return '#6b7280';
        }
    };

    const createCustomIcon = (type: string) => {
        const color = getMarkerColor(type);
        return L.divIcon({
            className: 'custom-marker',
            html: `<div style="
                background-color: ${color};
                width: 18px;
                height: 18px;
                border-radius: 50%;
                border: 2px solid white;
                box-shadow: 0 0 5px rgba(0,0,0,0.3);
            "></div>`,
            iconSize: [18, 18],
            iconAnchor: [9, 9],
        });
    };

    return (
        <div className="p-4 space-y-4 font-sans">
            <div className="flex flex-col gap-4 sm:flex-row sm:flex-wrap sm:items-center">
                <CityFilter />

                <div className="flex gap-2 overflow-x-auto pb-2 sm:pb-0">
                    {statusList.map((s) => (
                        <button
                            key={s}
                            onClick={() => setStatus(s)}
                            className={`px-4 py-1 rounded-full border transition-colors whitespace-nowrap ${status === s ? 'bg-blue-600 text-white border-blue-600' : 'bg-white hover:bg-gray-100'
                                }`}
                        >
                            {s}
                        </button>
                    ))}
                </div>
            </div>
            <div className="relative h-[430px] rounded-xl border shadow-inner overflow-hidden">
                {citiesLoading || !selectedCity ? (
                    <div className="h-full w-full flex flex-col items-center justify-center gap-2 bg-muted/30 text-muted-foreground text-sm px-4 text-center">
                        <span>Carregando municípios do Brasil…</span>
                        <span className="text-xs opacity-80">Na primeira vez o arquivo completo pode levar alguns segundos; depois fica em cache.</span>
                    </div>
                ) : (
                    <MapContainer
                        ref={mapRef}
                        center={[mapCenter.lat, mapCenter.lng]}
                        zoom={14}
                        className="h-full w-full"
                    >
                        <ChangeView lat={mapCenter.lat} lng={mapCenter.lng} />

                        <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                        <MapEvents />

                        {suggestions.map((s) => (
                            <Marker
                                key={s.id}
                                position={[s.latitude, s.longitude]}
                                icon={createCustomIcon(s.type)}
                                eventHandlers={{
                                    click: () => setSelectedSuggestion(s),
                                }}
                            />
                        ))}
                    </MapContainer>
                )}

                {loading && (
                    <div className="absolute inset-0 bg-white/40 backdrop-blur-[1px] z-[1000] flex items-center justify-center">
                        <div className="animate-spin h-10 w-10 border-4 border-blue-600 border-t-transparent rounded-full" />
                    </div>
                )}
            </div>

            {selectedSuggestion && (
                <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-[2000] p-4">
                    <div className="bg-white rounded-lg shadow-xl w-full max-w-md overflow-hidden animate-in fade-in zoom-in duration-200">
                        <div className="p-4 border-b flex justify-between items-center">
                            <h2 className="text-xl font-bold text-gray-800">
                                {selectedSuggestion.type}
                            </h2>
                            <span className="text-xs font-medium px-2 py-1 bg-gray-100 rounded text-gray-600">
                                {selectedSuggestion.status}
                            </span>
                        </div>

                        <div className="p-4 space-y-4">
                            {selectedSuggestion.suggestionImageUrl && (
                                <img
                                    src={selectedSuggestion.suggestionImageUrl}
                                    alt="Evidência"
                                    className="h-48 w-full object-cover rounded-lg shadow-sm"
                                />
                            )}

                            <div className="text-gray-700 leading-relaxed">
                                <p className="font-medium text-sm text-gray-500 uppercase">Descrição</p>
                                <p>{selectedSuggestion.description}</p>
                            </div>

                            <button
                                onClick={() => setSelectedSuggestion(null)}
                                className="w-full py-3 bg-gray-900 text-white rounded-lg font-medium hover:bg-black transition-colors"
                            >
                                Fechar
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
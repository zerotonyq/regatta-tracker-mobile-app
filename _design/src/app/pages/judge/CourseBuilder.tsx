import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ArrowLeft, Save, AlertCircle, CheckCircle, Plus, Trash2 } from 'lucide-react';
import { MapContainer, TileLayer, Marker, Polyline, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import { Button } from '../../components/Button';
import { Card } from '../../components/Card';
import { Badge } from '../../components/Badge';
import type { CoursePoint, CoursePointType, RaceType } from '../../types';
import 'leaflet/dist/leaflet.css';

// Fix Leaflet default marker icons
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

const POINT_COLORS: Record<CoursePointType, string> = {
  'start-line': '#10b981',
  'finish-line': '#dc2626',
  'mark': '#3b82f6',
  'gate-left': '#f59e0b',
  'gate-right': '#f59e0b',
  'offset-mark': '#8b5cf6',
};

const POINT_LABELS: Record<CoursePointType, string> = {
  'start-line': 'Старт',
  'finish-line': 'Финиш',
  'mark': 'Метка',
  'gate-left': 'Ворота (левые)',
  'gate-right': 'Ворота (правые)',
  'offset-mark': 'Offset метка',
};

export function CourseBuilder() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [name, setName] = useState('Новая трасса');
  const [raceType, setRaceType] = useState<RaceType>('windward-leeward');
  const [points, setPoints] = useState<CoursePoint[]>([]);
  const [selectedPointType, setSelectedPointType] = useState<CoursePointType>('mark');
  const [mapCenter] = useState<[number, number]>([59.9311, 30.3609]); // St. Petersburg
  const [validation, setValidation] = useState<{ valid: boolean; errors: string[] }>({
    valid: false,
    errors: [],
  });
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    validateCourse();
  }, [points, raceType]);

  const validateCourse = () => {
    const errors: string[] = [];

    if (points.length < 2) {
      errors.push('Минимум 2 точки необходимо');
      setValidation({ valid: false, errors });
      return;
    }

    const startPoints = points.filter(p => p.type === 'start-line');
    const finishPoints = points.filter(p => p.type === 'finish-line');

    if (startPoints.length < 1) {
      errors.push('Требуется стартовая линия');
    }

    if (finishPoints.length < 1) {
      errors.push('Требуется финишная линия');
    }

    if (raceType === 'windward-leeward') {
      const marks = points.filter(p => p.type === 'mark');
      if (marks.length < 1) {
        errors.push('W/L трасса требует минимум одну верхнюю метку');
      }

      const gates = points.filter(p => p.type === 'gate-left' || p.type === 'gate-right');
      if (gates.length > 0 && gates.length < 2) {
        errors.push('Ворота требуют обе метки (левую и правую)');
      }
    }

    setValidation({ valid: errors.length === 0, errors });
  };

  const handleMapClick = (lat: number, lng: number) => {
    const newPoint: CoursePoint = {
      id: `point-${Date.now()}`,
      type: selectedPointType,
      lat,
      lng,
      order: points.length,
    };
    setPoints([...points, newPoint]);
  };

  const removePoint = (id: string) => {
    setPoints(points.filter(p => p.id !== id).map((p, idx) => ({ ...p, order: idx })));
  };

  const handleSave = async () => {
    if (!validation.valid) return;

    setSaving(true);
    await new Promise(resolve => setTimeout(resolve, 1000));
    setSaving(false);
    navigate('/judge');
  };

  return (
    <div className="flex h-screen flex-col bg-background">
      {/* Header */}
      <div className="bg-primary px-4 py-3 text-primary-foreground">
        <div className="flex items-center justify-between">
          <button
            onClick={() => navigate(-1)}
            className="flex items-center gap-2 text-primary-foreground/80"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <h1 className="flex-1 text-center text-lg font-semibold">Конструктор трассы</h1>
          <Button
            onClick={handleSave}
            variant="secondary"
            size="sm"
            disabled={!validation.valid}
            loading={saving}
          >
            <Save className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Map */}
      <div className="relative flex-1">
        <MapContainer
          center={mapCenter}
          zoom={14}
          className="h-full w-full"
          zoomControl={false}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <MapClickHandler onMapClick={handleMapClick} />

          {/* Course points */}
          {points.map((point) => (
            <Marker
              key={point.id}
              position={[point.lat, point.lng]}
              icon={createIcon(point.type)}
            />
          ))}

          {/* Course line */}
          {points.length > 1 && (
            <Polyline
              positions={points.map(p => [p.lat, p.lng])}
              pathOptions={{ color: '#0066cc', weight: 3, dashArray: '8, 4', opacity: 0.7 }}
            />
          )}
        </MapContainer>

        {/* Validation Status */}
        {points.length > 0 && (
          <div className="absolute left-4 top-4 right-4 z-[1000]">
            <Card className={`p-3 ${validation.valid ? 'bg-success/10 border-success' : 'bg-warning/10 border-warning'}`}>
              <div className="flex items-start gap-2">
                {validation.valid ? (
                  <CheckCircle className="h-5 w-5 text-success flex-shrink-0" />
                ) : (
                  <AlertCircle className="h-5 w-5 text-warning flex-shrink-0" />
                )}
                <div className="flex-1 min-w-0">
                  {validation.valid ? (
                    <p className="text-sm font-medium text-success">Трасса валидна</p>
                  ) : (
                    <div className="text-sm">
                      <p className="font-medium text-warning mb-1">Ошибки:</p>
                      <ul className="space-y-0.5 text-xs text-muted-foreground">
                        {validation.errors.map((err, idx) => (
                          <li key={idx}>• {err}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>
              </div>
            </Card>
          </div>
        )}
      </div>

      {/* Bottom Panel */}
      <div className="border-t border-border bg-card">
        {/* Course Info */}
        <div className="border-b border-border p-4">
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="mb-3 w-full rounded-lg border border-input bg-input-background px-3 py-2 text-sm font-medium"
            placeholder="Название трассы"
          />

          <div className="mb-3">
            <label className="mb-2 block text-xs font-medium text-muted-foreground">Тип гонки</label>
            <div className="grid grid-cols-2 gap-2">
              {[
                { value: 'windward-leeward', label: 'Windward-Leeward' },
                { value: 'match-race', label: 'Match Race' },
              ].map(({ value, label }) => (
                <button
                  key={value}
                  type="button"
                  onClick={() => setRaceType(value as RaceType)}
                  className={`rounded-lg border-2 px-3 py-2 text-sm transition-all ${
                    raceType === value
                      ? 'border-primary bg-primary/5 text-primary font-medium'
                      : 'border-border bg-background'
                  }`}
                >
                  {label}
                </button>
              ))}
            </div>
          </div>

          <label className="mb-2 block text-xs font-medium text-muted-foreground">Добавить точку</label>
          <div className="grid grid-cols-3 gap-2">
            {(['start-line', 'finish-line', 'mark', 'gate-left', 'gate-right', 'offset-mark'] as CoursePointType[]).map(type => (
              <button
                key={type}
                type="button"
                onClick={() => setSelectedPointType(type)}
                className={`rounded-lg border-2 px-2 py-2 text-xs transition-all ${
                  selectedPointType === type
                    ? 'border-primary bg-primary/10 font-medium'
                    : 'border-border bg-background'
                }`}
              >
                <div
                  className="mx-auto mb-1 h-3 w-3 rounded-full"
                  style={{ backgroundColor: POINT_COLORS[type] }}
                />
                {POINT_LABELS[type]}
              </button>
            ))}
          </div>
          <p className="mt-2 text-xs text-muted-foreground">Нажмите на карту для добавления точки</p>
        </div>

        {/* Points List */}
        {points.length > 0 && (
          <div className="max-h-32 overflow-y-auto p-4">
            <div className="mb-2 flex items-center justify-between">
              <span className="text-xs font-medium text-muted-foreground">
                Точки трассы ({points.length})
              </span>
              <button
                onClick={() => setPoints([])}
                className="text-xs text-destructive"
              >
                Очистить все
              </button>
            </div>
            <div className="space-y-2">
              {points.map((point, idx) => (
                <div
                  key={point.id}
                  className="flex items-center justify-between rounded-lg bg-secondary p-2"
                >
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-medium text-muted-foreground">#{idx + 1}</span>
                    <div
                      className="h-3 w-3 rounded-full"
                      style={{ backgroundColor: POINT_COLORS[point.type] }}
                    />
                    <span className="text-sm">{POINT_LABELS[point.type]}</span>
                  </div>
                  <button
                    onClick={() => removePoint(point.id)}
                    className="rounded p-1 text-destructive hover:bg-destructive/10"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function MapClickHandler({ onMapClick }: { onMapClick: (lat: number, lng: number) => void }) {
  useMapEvents({
    click: (e) => {
      onMapClick(e.latlng.lat, e.latlng.lng);
    },
  });
  return null;
}

function createIcon(type: CoursePointType): L.DivIcon {
  const color = POINT_COLORS[type];
  return L.divIcon({
    className: 'race-marker',
    html: `<div style="width: 24px; height: 24px; background: ${color}; border: 3px solid white; border-radius: 50%; box-shadow: 0 2px 8px rgba(0,0,0,0.2);"></div>`,
    iconSize: [24, 24],
    iconAnchor: [12, 12],
  });
}

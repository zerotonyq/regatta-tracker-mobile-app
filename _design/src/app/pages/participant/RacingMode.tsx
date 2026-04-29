import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ArrowLeft, Navigation, Activity, Clock, Users } from 'lucide-react';
import { Card } from '../../components/Card';
import { Badge } from '../../components/Badge';
import { mockRaces } from '../../mockData';
import { formatTime, calculateDuration } from '../../utils';

export function RacingMode() {
  const navigate = useNavigate();
  const { id } = useParams();
  const race = mockRaces.find(r => r.id === id);

  const [elapsed, setElapsed] = useState('0м 0с');
  const [gpsActive, setGpsActive] = useState(true);
  const [speed, setSpeed] = useState(8.5);
  const [heading, setHeading] = useState(45);
  const [lastSent, setLastSent] = useState<Date>(new Date());

  useEffect(() => {
    if (!race?.actualStart) return;

    const timer = setInterval(() => {
      setElapsed(calculateDuration(race.actualStart!, new Date()));
    }, 1000);

    return () => clearInterval(timer);
  }, [race?.actualStart]);

  useEffect(() => {
    // Simulate GPS updates
    const gpsTimer = setInterval(() => {
      setSpeed(prev => prev + (Math.random() - 0.5) * 0.5);
      setHeading(prev => (prev + (Math.random() - 0.5) * 5) % 360);
      setLastSent(new Date());
    }, (race?.trackingInterval || 5) * 1000);

    return () => clearInterval(gpsTimer);
  }, [race?.trackingInterval]);

  if (!race) {
    return <div className="p-4">Гонка не найдена</div>;
  }

  const myParticipant = race.participants[0]; // Mock
  const currentPosition = 2;
  const totalParticipants = race.participants.length;

  return (
    <div className="flex h-screen flex-col bg-gradient-to-br from-race-active/10 to-primary/5">
      {/* Minimal Header */}
      <div className="bg-race-active px-4 py-3 text-white">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center gap-2 text-white/80"
        >
          <ArrowLeft className="h-5 w-5" />
          <span className="text-sm">Выйти</span>
        </button>
      </div>

      {/* Main Racing Display - Hands-free, large text */}
      <div className="flex-1 flex flex-col items-center justify-center p-6 space-y-8">
        {/* Race Name */}
        <div className="text-center">
          <h1 className="text-2xl font-bold mb-1">{race.name}</h1>
          <p className="text-muted-foreground">Режим гонки</p>
        </div>

        {/* Position Display - Large */}
        <Card className="w-full max-w-md p-8 bg-white/80 backdrop-blur">
          <div className="text-center">
            <div className="mb-2 text-sm font-medium text-muted-foreground">Текущая позиция</div>
            <div className="mb-4 text-7xl font-bold text-primary">{currentPosition}</div>
            <div className="text-lg text-muted-foreground">из {totalParticipants}</div>
          </div>
        </Card>

        {/* Elapsed Time - Large */}
        <div className="text-center">
          <div className="mb-2 flex items-center justify-center gap-2 text-muted-foreground">
            <Clock className="h-5 w-5" />
            <span className="text-sm font-medium">Прошло времени</span>
          </div>
          <div className="text-5xl font-bold text-foreground">{elapsed}</div>
        </div>

        {/* GPS Status */}
        <div className="w-full max-w-md space-y-3">
          <Card className={`p-4 ${gpsActive ? 'bg-success/10 border-success/30' : 'bg-destructive/10 border-destructive/30'}`}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className={`h-3 w-3 rounded-full ${gpsActive ? 'bg-success animate-pulse' : 'bg-destructive'}`} />
                <div>
                  <div className="text-sm font-medium">GPS трекинг</div>
                  <div className="text-xs text-muted-foreground">
                    {gpsActive ? `Каждые ${race.trackingInterval}с` : 'Не активен'}
                  </div>
                </div>
              </div>
              {gpsActive && <Activity className="h-5 w-5 text-success" />}
            </div>
          </Card>

          {/* Speed & Heading */}
          <div className="grid grid-cols-2 gap-3">
            <Card className="p-4 text-center">
              <div className="mb-1 text-xs text-muted-foreground">Скорость</div>
              <div className="text-2xl font-bold">{speed.toFixed(1)}</div>
              <div className="text-xs text-muted-foreground">узлов</div>
            </Card>
            <Card className="p-4 text-center">
              <div className="mb-1 text-xs text-muted-foreground">Курс</div>
              <div className="text-2xl font-bold">{Math.round(heading)}°</div>
              <div className="text-xs text-muted-foreground">
                <Navigation className="inline h-3 w-3" />
              </div>
            </Card>
          </div>
        </div>
      </div>

      {/* Bottom Info Bar */}
      <div className="bg-card border-t border-border px-4 py-3">
        <div className="mx-auto max-w-md flex items-center justify-between text-xs text-muted-foreground">
          <span>Последняя отправка: {formatTime(lastSent)}</span>
          <Badge variant="success" size="sm">
            <Activity className="mr-1 h-3 w-3" />
            Активна
          </Badge>
        </div>
      </div>

      {/* Important: Screen wake lock hint */}
      <div className="bg-warning/10 border-t border-warning/30 px-4 py-2 text-center text-xs text-muted-foreground">
        Держите экран разблокированным для корректной работы GPS
      </div>
    </div>
  );
}

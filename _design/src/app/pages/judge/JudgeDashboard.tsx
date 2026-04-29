import { useNavigate } from 'react-router';
import { Plus, Map, Settings as SettingsIcon, Calendar, Play, CheckCircle } from 'lucide-react';
import { Card } from '../../components/Card';
import { Button } from '../../components/Button';
import { RaceStatusBadge } from '../../components/Badge';
import { mockRaces } from '../../mockData';
import { formatDateTime, formatTime } from '../../utils';
import type { Race } from '../../types';

export function JudgeDashboard() {
  const navigate = useNavigate();

  const activeRaces = mockRaces.filter(r => r.status === 'active');
  const upcomingRaces = mockRaces.filter(r => r.status === 'planned' || r.status === 'ready');
  const completedRaces = mockRaces.filter(r => r.status === 'finished');

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-primary px-4 py-6 text-primary-foreground">
        <div className="mx-auto max-w-2xl">
          <div className="mb-4 flex items-center justify-between">
            <h1 className="text-2xl font-bold">Панель судьи</h1>
            <button
              onClick={() => navigate('/settings')}
              className="rounded-lg p-2 hover:bg-white/10"
            >
              <SettingsIcon className="h-6 w-6" />
            </button>
          </div>
          <p className="text-primary-foreground/80">Управление гонками и трассами</p>
        </div>
      </div>

      <div className="mx-auto max-w-2xl px-4 py-6 space-y-6">
        {/* Quick Actions */}
        <div className="grid grid-cols-2 gap-3">
          <Button
            onClick={() => navigate('/judge/race/new')}
            variant="primary"
            size="lg"
            className="flex-col gap-2 h-auto py-4"
          >
            <Plus className="h-6 w-6" />
            Новая гонка
          </Button>
          <Button
            onClick={() => navigate('/judge/course/new')}
            variant="outline"
            size="lg"
            className="flex-col gap-2 h-auto py-4"
          >
            <Map className="h-6 w-6" />
            Трасса
          </Button>
        </div>

        {/* Active Races */}
        {activeRaces.length > 0 && (
          <section>
            <div className="mb-3 flex items-center gap-2">
              <Play className="h-5 w-5 text-race-active" />
              <h2 className="text-lg font-semibold">Активные гонки</h2>
            </div>
            <div className="space-y-3">
              {activeRaces.map(race => (
                <RaceCard key={race.id} race={race} onClick={() => navigate(`/judge/race/${race.id}`)} />
              ))}
            </div>
          </section>
        )}

        {/* Upcoming Races */}
        {upcomingRaces.length > 0 && (
          <section>
            <div className="mb-3 flex items-center gap-2">
              <Calendar className="h-5 w-5 text-race-planned" />
              <h2 className="text-lg font-semibold">Предстоящие</h2>
            </div>
            <div className="space-y-3">
              {upcomingRaces.map(race => (
                <RaceCard key={race.id} race={race} onClick={() => navigate(`/judge/race/${race.id}`)} />
              ))}
            </div>
          </section>
        )}

        {/* Completed Races */}
        {completedRaces.length > 0 && (
          <section>
            <div className="mb-3 flex items-center gap-2">
              <CheckCircle className="h-5 w-5 text-race-finished" />
              <h2 className="text-lg font-semibold">Завершенные</h2>
            </div>
            <div className="space-y-3">
              {completedRaces.map(race => (
                <RaceCard key={race.id} race={race} onClick={() => navigate(`/judge/race/${race.id}`)} />
              ))}
            </div>
          </section>
        )}
      </div>
    </div>
  );
}

function RaceCard({ race, onClick }: { race: Race; onClick: () => void }) {
  return (
    <Card interactive onClick={onClick}>
      <div className="space-y-3">
        <div className="flex items-start justify-between gap-3">
          <div className="flex-1 min-w-0">
            <h3 className="font-semibold truncate">{race.name}</h3>
            <p className="text-sm text-muted-foreground">
              {race.course?.name || 'Без трассы'}
            </p>
          </div>
          <RaceStatusBadge status={race.status} />
        </div>

        <div className="flex items-center justify-between text-sm">
          <div className="text-muted-foreground">
            {race.scheduledStart && (
              <div className="flex items-center gap-1">
                <Calendar className="h-4 w-4" />
                {formatTime(race.scheduledStart)}
              </div>
            )}
          </div>
          <div className="font-medium">
            {race.participants.length} участников
          </div>
        </div>
      </div>
    </Card>
  );
}

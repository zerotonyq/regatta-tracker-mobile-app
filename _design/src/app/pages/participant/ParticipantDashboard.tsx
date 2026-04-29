import { useNavigate } from 'react-router';
import { Settings as SettingsIcon, Play, Calendar, CheckCircle, Clock } from 'lucide-react';
import { Card } from '../../components/Card';
import { RaceStatusBadge, Badge } from '../../components/Badge';
import { mockRaces } from '../../mockData';
import { formatDateTime, formatTime } from '../../utils';
import type { Race } from '../../types';

export function ParticipantDashboard() {
  const navigate = useNavigate();

  // Filter races for participant
  const activeRaces = mockRaces.filter(r => r.status === 'active');
  const upcomingRaces = mockRaces.filter(r => r.status === 'planned' || r.status === 'ready');
  const completedRaces = mockRaces.filter(r => r.status === 'finished');

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-primary px-4 py-6 text-primary-foreground">
        <div className="mx-auto max-w-2xl">
          <div className="mb-4 flex items-center justify-between">
            <h1 className="text-2xl font-bold">Мои гонки</h1>
            <button
              onClick={() => navigate('/settings')}
              className="rounded-lg p-2 hover:bg-white/10"
            >
              <SettingsIcon className="h-6 w-6" />
            </button>
          </div>
          <p className="text-primary-foreground/80">Участие в регатах</p>
        </div>
      </div>

      <div className="mx-auto max-w-2xl px-4 py-6 space-y-6">
        {/* Active Race Alert */}
        {activeRaces.length > 0 && (
          <Card className="p-4 bg-race-active/10 border-race-active/30">
            <div className="mb-3 flex items-center gap-2">
              <Play className="h-5 w-5 text-race-active" />
              <h2 className="font-semibold text-race-active">Активная гонка</h2>
            </div>
            {activeRaces.map(race => (
              <div key={race.id} className="mb-3 last:mb-0">
                <div className="mb-2 font-medium">{race.name}</div>
                <div className="mb-3 text-sm text-muted-foreground">
                  Началась {race.actualStart && formatTime(race.actualStart)}
                </div>
                <div
                  onClick={() => navigate(`/participant/racing/${race.id}`)}
                  className="w-full rounded-lg bg-race-active p-4 text-white text-center font-semibold shadow-lg active:scale-[0.98] transition-transform cursor-pointer"
                >
                  Перейти к гонке
                </div>
              </div>
            ))}
          </Card>
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
                <ParticipantRaceCard
                  key={race.id}
                  race={race}
                  onClick={() => navigate(`/participant/race/${race.id}`)}
                />
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
                <ParticipantRaceCard
                  key={race.id}
                  race={race}
                  onClick={() => navigate(`/participant/race/${race.id}`)}
                />
              ))}
            </div>
          </section>
        )}

        {/* Empty State */}
        {activeRaces.length === 0 && upcomingRaces.length === 0 && completedRaces.length === 0 && (
          <Card className="p-8 text-center">
            <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-muted">
              <Calendar className="h-8 w-8 text-muted-foreground" />
            </div>
            <h3 className="mb-2 text-lg font-semibold">Нет гонок</h3>
            <p className="text-sm text-muted-foreground">
              Вы пока не участвуете ни в одной гонке
            </p>
          </Card>
        )}
      </div>
    </div>
  );
}

function ParticipantRaceCard({ race, onClick }: { race: Race; onClick: () => void }) {
  const myParticipant = race.participants[0]; // Mock: first participant is current user

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

        {race.scheduledStart && (
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <Clock className="h-4 w-4" />
            {formatDateTime(race.scheduledStart)}
          </div>
        )}

        {myParticipant && (
          <div className="flex items-center justify-between text-sm">
            <span className="text-muted-foreground">
              {myParticipant.boatName} • {myParticipant.sailNumber}
            </span>
            {myParticipant.position && (
              <Badge variant="success">
                {myParticipant.position} место
              </Badge>
            )}
          </div>
        )}
      </div>
    </Card>
  );
}

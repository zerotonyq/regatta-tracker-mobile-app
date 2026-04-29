import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ArrowLeft, Play, Square, Users, Clock, MapPin, Calendar } from 'lucide-react';
import { Button } from '../../components/Button';
import { Card } from '../../components/Card';
import { RaceStatusBadge, Badge } from '../../components/Badge';
import { mockRaces } from '../../mockData';
import { formatDateTime, formatTime, calculateDuration } from '../../utils';

export function RaceDetails() {
  const navigate = useNavigate();
  const { id } = useParams();
  const race = mockRaces.find(r => r.id === id);

  const [localRace, setLocalRace] = useState(race);
  const [actionLoading, setActionLoading] = useState(false);

  if (!localRace) {
    return <div className="p-4">Гонка не найдена</div>;
  }

  const handleStartRace = async () => {
    setActionLoading(true);
    await new Promise(resolve => setTimeout(resolve, 1500));

    setLocalRace({
      ...localRace,
      status: 'active',
      actualStart: new Date().toISOString(),
    });
    setActionLoading(false);
  };

  const handleEndRace = async () => {
    setActionLoading(true);
    await new Promise(resolve => setTimeout(resolve, 1500));

    setLocalRace({
      ...localRace,
      status: 'finished',
      actualEnd: new Date().toISOString(),
    });
    setActionLoading(false);
  };

  const canStart = localRace.status === 'ready' || localRace.status === 'planned';
  const canEnd = localRace.status === 'active';

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-primary px-4 py-4 text-primary-foreground">
        <div className="mx-auto max-w-2xl">
          <button
            onClick={() => navigate(-1)}
            className="mb-3 flex items-center gap-2 text-primary-foreground/80"
          >
            <ArrowLeft className="h-5 w-5" />
            Назад
          </button>
          <div className="mb-2 flex items-start justify-between gap-3">
            <h1 className="flex-1 text-xl font-bold">{localRace.name}</h1>
            <RaceStatusBadge status={localRace.status} />
          </div>
        </div>
      </div>

      <div className="mx-auto max-w-2xl px-4 py-6 space-y-4">
        {/* Race Control */}
        {canStart && (
          <Card className="p-4 bg-success/5 border-success/20">
            <div className="mb-3 text-center">
              <h3 className="text-lg font-semibold mb-1">Готовы начать?</h3>
              <p className="text-sm text-muted-foreground">
                {localRace.participants.filter(p => p.status === 'confirmed').length} участников подтвердили участие
              </p>
            </div>
            <Button
              onClick={handleStartRace}
              variant="success"
              size="xl"
              fullWidth
              loading={actionLoading}
            >
              <Play className="mr-2 h-6 w-6" />
              Начать гонку
            </Button>
          </Card>
        )}

        {canEnd && (
          <Card className="p-4 bg-destructive/5 border-destructive/20">
            <div className="mb-3 text-center">
              <h3 className="text-lg font-semibold mb-1">Завершить гонку</h3>
              <p className="text-sm text-muted-foreground">
                {localRace.actualStart && `Началась ${formatTime(localRace.actualStart)}`}
              </p>
            </div>
            <Button
              onClick={handleEndRace}
              variant="danger"
              size="xl"
              fullWidth
              loading={actionLoading}
            >
              <Square className="mr-2 h-6 w-6" />
              Закончить гонку
            </Button>
          </Card>
        )}

        {/* Race Info */}
        <Card className="p-4">
          <h3 className="mb-3 font-semibold">Информация о гонке</h3>
          <div className="space-y-3">
            <div className="flex items-start gap-3">
              <MapPin className="h-5 w-5 text-muted-foreground flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-sm font-medium">Трасса</div>
                <div className="text-sm text-muted-foreground">
                  {localRace.course?.name || 'Не выбрана'}
                </div>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <Calendar className="h-5 w-5 text-muted-foreground flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-sm font-medium">Запланированный старт</div>
                <div className="text-sm text-muted-foreground">
                  {localRace.scheduledStart ? formatDateTime(localRace.scheduledStart) : 'Не указан'}
                </div>
              </div>
            </div>

            {localRace.actualStart && (
              <div className="flex items-start gap-3">
                <Clock className="h-5 w-5 text-muted-foreground flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <div className="text-sm font-medium">Фактический старт</div>
                  <div className="text-sm text-muted-foreground">
                    {formatDateTime(localRace.actualStart)}
                  </div>
                </div>
              </div>
            )}

            {localRace.actualEnd && (
              <div className="flex items-start gap-3">
                <Clock className="h-5 w-5 text-muted-foreground flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <div className="text-sm font-medium">Завершена</div>
                  <div className="text-sm text-muted-foreground">
                    {formatDateTime(localRace.actualEnd)}
                  </div>
                  {localRace.actualStart && (
                    <div className="mt-1 text-xs font-medium text-primary">
                      Длительность: {calculateDuration(localRace.actualStart, localRace.actualEnd)}
                    </div>
                  )}
                </div>
              </div>
            )}

            <div className="flex items-start gap-3">
              <Clock className="h-5 w-5 text-muted-foreground flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-sm font-medium">GPS интервал</div>
                <div className="text-sm text-muted-foreground">
                  Каждые {localRace.trackingInterval} секунд
                </div>
              </div>
            </div>
          </div>
        </Card>

        {/* Participants */}
        <Card className="p-4">
          <div className="mb-3 flex items-center justify-between">
            <h3 className="font-semibold">Участники</h3>
            <Badge variant="default">{localRace.participants.length}</Badge>
          </div>
          <div className="space-y-2">
            {localRace.participants.map(participant => (
              <div
                key={participant.id}
                className="flex items-center justify-between rounded-lg bg-secondary p-3"
              >
                <div className="flex-1">
                  <div className="font-medium">{participant.userName}</div>
                  <div className="text-sm text-muted-foreground">
                    {participant.boatName && `${participant.boatName} • `}
                    {participant.sailNumber}
                  </div>
                </div>
                <ParticipantStatusBadge status={participant.status} position={participant.position} />
              </div>
            ))}
          </div>
        </Card>

        {/* Results */}
        {localRace.status === 'finished' && (
          <Card className="p-4">
            <h3 className="mb-3 font-semibold">Результаты</h3>
            <div className="space-y-2">
              {localRace.participants
                .filter(p => p.finishTime)
                .sort((a, b) => (a.position || 999) - (b.position || 999))
                .map(participant => (
                  <div
                    key={participant.id}
                    className="flex items-center gap-3 rounded-lg bg-secondary p-3"
                  >
                    <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground font-bold text-sm">
                      {participant.position}
                    </div>
                    <div className="flex-1">
                      <div className="font-medium">{participant.userName}</div>
                      <div className="text-xs text-muted-foreground">
                        {participant.finishTime && formatTime(participant.finishTime)}
                      </div>
                    </div>
                  </div>
                ))}
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}

function ParticipantStatusBadge({ status, position }: { status: string; position?: number }) {
  const config = {
    invited: { label: 'Приглашен', variant: 'default' as const },
    confirmed: { label: 'Подтвержден', variant: 'info' as const },
    racing: { label: 'В гонке', variant: 'active' as const },
    finished: { label: position ? `${position} место` : 'Финишировал', variant: 'success' as const },
    dnf: { label: 'DNF', variant: 'danger' as const },
  };

  const statusConfig = config[status as keyof typeof config] || config.invited;

  return <Badge variant={statusConfig.variant} size="sm">{statusConfig.label}</Badge>;
}

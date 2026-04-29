import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ArrowLeft, MapPin, Calendar, Clock, CheckCircle, X } from 'lucide-react';
import { Button } from '../../components/Button';
import { Card } from '../../components/Card';
import { RaceStatusBadge, Badge } from '../../components/Badge';
import { mockRaces } from '../../mockData';
import { formatDateTime, formatTime } from '../../utils';

export function RaceView() {
  const navigate = useNavigate();
  const { id } = useParams();
  const race = mockRaces.find(r => r.id === id);
  const [confirmStatus, setConfirmStatus] = useState<'confirmed' | 'declined' | null>(null);
  const [loading, setLoading] = useState(false);

  if (!race) {
    return <div className="p-4">Гонка не найдена</div>;
  }

  const myParticipant = race.participants[0]; // Mock
  const canConfirm = race.status === 'planned' && !confirmStatus;

  const handleConfirm = async (status: 'confirmed' | 'declined') => {
    setLoading(true);
    await new Promise(resolve => setTimeout(resolve, 1000));
    setConfirmStatus(status);
    setLoading(false);
  };

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
            <h1 className="flex-1 text-xl font-bold">{race.name}</h1>
            <RaceStatusBadge status={race.status} />
          </div>
        </div>
      </div>

      <div className="mx-auto max-w-2xl px-4 py-6 space-y-4">
        {/* Confirmation Actions */}
        {canConfirm && (
          <Card className="p-4 bg-info/5 border-info/20">
            <div className="mb-4 text-center">
              <h3 className="text-lg font-semibold mb-1">Подтвердите участие</h3>
              <p className="text-sm text-muted-foreground">
                Вы получили приглашение на эту гонку
              </p>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Button
                onClick={() => handleConfirm('confirmed')}
                variant="success"
                loading={loading}
              >
                <CheckCircle className="mr-2 h-5 w-5" />
                Принять
              </Button>
              <Button
                onClick={() => handleConfirm('declined')}
                variant="danger"
                loading={loading}
              >
                <X className="mr-2 h-5 w-5" />
                Отклонить
              </Button>
            </div>
          </Card>
        )}

        {confirmStatus === 'confirmed' && (
          <Card className="p-4 bg-success/10 border-success/30">
            <div className="flex items-center gap-3">
              <CheckCircle className="h-6 w-6 text-success" />
              <div>
                <div className="font-semibold text-success">Участие подтверждено</div>
                <div className="text-sm text-muted-foreground">
                  Вы получите уведомление о начале гонки
                </div>
              </div>
            </div>
          </Card>
        )}

        {/* My Info */}
        {myParticipant && (
          <Card className="p-4">
            <h3 className="mb-3 font-semibold">Моя информация</h3>
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">Яхта</span>
                <span className="font-medium">{myParticipant.boatName}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">Парусный номер</span>
                <span className="font-medium">{myParticipant.sailNumber}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">Статус</span>
                <ParticipantStatusBadge status={myParticipant.status} />
              </div>
              {myParticipant.position && (
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Позиция</span>
                  <Badge variant="success">{myParticipant.position} место</Badge>
                </div>
              )}
            </div>
          </Card>
        )}

        {/* Race Info */}
        <Card className="p-4">
          <h3 className="mb-3 font-semibold">Детали гонки</h3>
          <div className="space-y-3">
            <div className="flex items-start gap-3">
              <MapPin className="h-5 w-5 text-muted-foreground flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-sm font-medium">Трасса</div>
                <div className="text-sm text-muted-foreground">
                  {race.course?.name || 'Не выбрана'}
                </div>
                {race.course && (
                  <div className="mt-1 text-xs text-muted-foreground">
                    {race.course.raceType} • {race.course.points.length} точек
                  </div>
                )}
              </div>
            </div>

            {race.scheduledStart && (
              <div className="flex items-start gap-3">
                <Calendar className="h-5 w-5 text-muted-foreground flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <div className="text-sm font-medium">Запланированный старт</div>
                  <div className="text-sm text-muted-foreground">
                    {formatDateTime(race.scheduledStart)}
                  </div>
                </div>
              </div>
            )}

            {race.actualStart && (
              <div className="flex items-start gap-3">
                <Clock className="h-5 w-5 text-muted-foreground flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <div className="text-sm font-medium">Фактический старт</div>
                  <div className="text-sm text-muted-foreground">
                    {formatDateTime(race.actualStart)}
                  </div>
                </div>
              </div>
            )}

            <div className="flex items-start gap-3">
              <Clock className="h-5 w-5 text-muted-foreground flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-sm font-medium">GPS интервал</div>
                <div className="text-sm text-muted-foreground">
                  Каждые {race.trackingInterval} секунд
                </div>
              </div>
            </div>
          </div>
        </Card>

        {/* Other Participants */}
        <Card className="p-4">
          <div className="mb-3 flex items-center justify-between">
            <h3 className="font-semibold">Участники</h3>
            <Badge variant="default">{race.participants.length}</Badge>
          </div>
          <div className="space-y-2">
            {race.participants.slice(1).map(participant => (
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
                {participant.position && (
                  <Badge variant="success" size="sm">
                    {participant.position}
                  </Badge>
                )}
              </div>
            ))}
          </div>
        </Card>

        {/* Instructions */}
        {race.status === 'planned' && confirmStatus === 'confirmed' && (
          <Card className="p-4 bg-info/5 border-info/20">
            <h3 className="mb-2 font-semibold text-sm">Подготовка к гонке</h3>
            <ul className="space-y-2 text-sm text-muted-foreground">
              <li className="flex gap-2">
                <span>•</span>
                <span>Убедитесь, что GPS включен</span>
              </li>
              <li className="flex gap-2">
                <span>•</span>
                <span>Зарядите телефон</span>
              </li>
              <li className="flex gap-2">
                <span>•</span>
                <span>При старте гонки вы получите уведомление</span>
              </li>
              <li className="flex gap-2">
                <span>•</span>
                <span>Во время гонки не нужно взаимодействовать с телефоном</span>
              </li>
            </ul>
          </Card>
        )}
      </div>
    </div>
  );
}

function ParticipantStatusBadge({ status }: { status: string }) {
  const config = {
    invited: { label: 'Приглашен', variant: 'default' as const },
    confirmed: { label: 'Подтвержден', variant: 'info' as const },
    racing: { label: 'В гонке', variant: 'active' as const },
    finished: { label: 'Финишировал', variant: 'success' as const },
    dnf: { label: 'DNF', variant: 'danger' as const },
  };

  const statusConfig = config[status as keyof typeof config] || config.invited;

  return <Badge variant={statusConfig.variant} size="sm">{statusConfig.label}</Badge>;
}

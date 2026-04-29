import { useNavigate } from 'react-router';
import { Anchor, Users } from 'lucide-react';
import { Card } from '../components/Card';
import { setCurrentUser, mockJudge, mockParticipant } from '../mockData';

export function RoleSelect() {
  const navigate = useNavigate();

  const handleRoleSelect = (role: 'judge' | 'participant') => {
    if (role === 'judge') {
      setCurrentUser(mockJudge);
      navigate('/judge');
    } else {
      setCurrentUser(mockParticipant);
      navigate('/participant');
    }
  };

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-gradient-to-br from-blue-50 to-blue-100 p-4">
      <div className="mb-8 text-center">
        <div className="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-primary shadow-lg">
          <Anchor className="h-10 w-10 text-primary-foreground" />
        </div>
        <h1 className="mb-2 text-3xl font-bold text-foreground">Регата Трекер</h1>
        <p className="text-muted-foreground">Система трекинга парусных регат</p>
      </div>

      <div className="w-full max-w-md space-y-4">
        <Card
          interactive
          onClick={() => handleRoleSelect('judge')}
          className="p-6"
        >
          <div className="flex items-start gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
              <Users className="h-6 w-6 text-primary" />
            </div>
            <div className="flex-1">
              <h3 className="mb-1 text-lg font-semibold">Судья</h3>
              <p className="text-sm text-muted-foreground">
                Создание гонок, управление трассами и контроль соревнований
              </p>
            </div>
          </div>
        </Card>

        <Card
          interactive
          onClick={() => handleRoleSelect('participant')}
          className="p-6"
        >
          <div className="flex items-start gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-accent/20">
              <Anchor className="h-6 w-6 text-accent" />
            </div>
            <div className="flex-1">
              <h3 className="mb-1 text-lg font-semibold">Участник</h3>
              <p className="text-sm text-muted-foreground">
                Участие в гонках с автоматическим трекингом GPS
              </p>
            </div>
          </div>
        </Card>
      </div>

      <div className="mt-8 text-center text-sm text-muted-foreground space-y-2">
        <p>Демо-версия • Все данные для примера</p>
        <button
          onClick={() => navigate('/design-system')}
          className="text-primary hover:underline"
        >
          Открыть Design System →
        </button>
      </div>
    </div>
  );
}

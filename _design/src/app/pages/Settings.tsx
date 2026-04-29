import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Navigation, Battery, Bell, Shield, LogOut, User } from 'lucide-react';
import { Button } from '../components/Button';
import { Card } from '../components/Card';
import { getCurrentUser } from '../mockData';

export function Settings() {
  const navigate = useNavigate();
  const user = getCurrentUser();
  const [gpsPermission, setGpsPermission] = useState(true);
  const [notifications, setNotifications] = useState(true);
  const [backgroundTracking, setBackgroundTracking] = useState(true);

  const handleLogout = () => {
    navigate('/');
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
          <h1 className="text-2xl font-bold">Настройки</h1>
        </div>
      </div>

      <div className="mx-auto max-w-2xl px-4 py-6 space-y-4">
        {/* Profile */}
        <Card className="p-4">
          <div className="mb-4 flex items-center gap-4">
            <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
              <User className="h-8 w-8 text-primary" />
            </div>
            <div className="flex-1">
              <div className="font-semibold text-lg">{user.name}</div>
              <div className="text-sm text-muted-foreground">{user.email}</div>
              <div className="mt-1 inline-block rounded-full bg-primary/10 px-2 py-0.5 text-xs font-medium text-primary">
                {user.role === 'judge' ? 'Судья' : 'Участник'}
              </div>
            </div>
          </div>
        </Card>

        {/* GPS & Location */}
        {user.role === 'participant' && (
          <>
            <Card className="p-4">
              <h3 className="mb-4 flex items-center gap-2 font-semibold">
                <Navigation className="h-5 w-5 text-primary" />
                GPS и местоположение
              </h3>

              <div className="space-y-4">
                <SettingToggle
                  label="GPS трекинг"
                  description="Разрешить доступ к местоположению"
                  icon={<Navigation className="h-5 w-5" />}
                  enabled={gpsPermission}
                  onChange={setGpsPermission}
                />

                <SettingToggle
                  label="Фоновый трекинг"
                  description="Отправка GPS даже при блокировке экрана"
                  icon={<Shield className="h-5 w-5" />}
                  enabled={backgroundTracking}
                  onChange={setBackgroundTracking}
                />
              </div>

              {!gpsPermission && (
                <div className="mt-4 rounded-lg bg-warning/10 border border-warning/30 p-3 text-sm text-muted-foreground">
                  GPS необходим для участия в гонках
                </div>
              )}
            </Card>

            <Card className="p-4">
              <h3 className="mb-4 flex items-center gap-2 font-semibold">
                <Battery className="h-5 w-5 text-primary" />
                Батарея
              </h3>
              <div className="space-y-3 text-sm text-muted-foreground">
                <div className="flex items-start gap-2">
                  <span>•</span>
                  <span>Используйте режим энергосбережения на яхте</span>
                </div>
                <div className="flex items-start gap-2">
                  <span>•</span>
                  <span>Отключите ненужные приложения</span>
                </div>
                <div className="flex items-start gap-2">
                  <span>•</span>
                  <span>Рекомендуется внешний аккумулятор</span>
                </div>
              </div>
            </Card>
          </>
        )}

        {/* Notifications */}
        <Card className="p-4">
          <h3 className="mb-4 flex items-center gap-2 font-semibold">
            <Bell className="h-5 w-5 text-primary" />
            Уведомления
          </h3>
          <SettingToggle
            label="Push-уведомления"
            description="О начале и окончании гонок"
            icon={<Bell className="h-5 w-5" />}
            enabled={notifications}
            onChange={setNotifications}
          />
        </Card>

        {/* About */}
        <Card className="p-4">
          <h3 className="mb-3 font-semibold">О приложении</h3>
          <div className="space-y-2 text-sm text-muted-foreground">
            <div className="flex justify-between">
              <span>Версия</span>
              <span className="font-medium">1.0.0 (Demo)</span>
            </div>
            <div className="flex justify-between">
              <span>Build</span>
              <span className="font-medium">2026.04.13</span>
            </div>
          </div>
        </Card>

        {/* Logout */}
        <div className="pt-4">
          <Button
            onClick={handleLogout}
            variant="danger"
            fullWidth
          >
            <LogOut className="mr-2 h-5 w-5" />
            Выйти
          </Button>
        </div>
      </div>
    </div>
  );
}

function SettingToggle({
  label,
  description,
  icon,
  enabled,
  onChange,
}: {
  label: string;
  description: string;
  icon: React.ReactNode;
  enabled: boolean;
  onChange: (value: boolean) => void;
}) {
  return (
    <div className="flex items-start justify-between gap-4">
      <div className="flex items-start gap-3 flex-1">
        <div className="mt-0.5 text-muted-foreground">{icon}</div>
        <div className="flex-1">
          <div className="font-medium">{label}</div>
          <div className="text-sm text-muted-foreground">{description}</div>
        </div>
      </div>
      <button
        onClick={() => onChange(!enabled)}
        className={`relative h-7 w-12 rounded-full transition-colors ${
          enabled ? 'bg-success' : 'bg-muted'
        }`}
      >
        <div
          className={`absolute top-1 h-5 w-5 rounded-full bg-white shadow-sm transition-transform ${
            enabled ? 'translate-x-6' : 'translate-x-1'
          }`}
        />
      </button>
    </div>
  );
}

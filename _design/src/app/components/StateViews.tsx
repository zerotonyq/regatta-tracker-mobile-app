import { Loader2, WifiOff, Navigation, AlertCircle, CheckCircle } from 'lucide-react';
import { Card } from './Card';
import { Button } from './Button';

export function LoadingView({ message = 'Загрузка...' }: { message?: string }) {
  return (
    <div className="flex min-h-[400px] flex-col items-center justify-center p-8">
      <Loader2 className="h-12 w-12 animate-spin text-primary mb-4" />
      <p className="text-muted-foreground">{message}</p>
    </div>
  );
}

export function NoInternetView({ onRetry }: { onRetry?: () => void }) {
  return (
    <div className="flex min-h-[400px] flex-col items-center justify-center p-8">
      <div className="mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-warning/10">
        <WifiOff className="h-10 w-10 text-warning" />
      </div>
      <h3 className="mb-2 text-lg font-semibold">Нет соединения</h3>
      <p className="mb-6 text-center text-sm text-muted-foreground">
        Проверьте подключение к интернету
      </p>
      {onRetry && (
        <Button onClick={onRetry} variant="primary">
          Повторить
        </Button>
      )}
    </div>
  );
}

export function NoGPSView({ onEnable }: { onEnable?: () => void }) {
  return (
    <Card className="p-6 bg-warning/5 border-warning/20">
      <div className="flex items-start gap-4">
        <div className="flex h-12 w-12 items-center justify-center rounded-full bg-warning/10 flex-shrink-0">
          <Navigation className="h-6 w-6 text-warning" />
        </div>
        <div className="flex-1">
          <h3 className="mb-1 font-semibold">GPS не активен</h3>
          <p className="mb-3 text-sm text-muted-foreground">
            Для участия в гонке необходимо включить GPS
          </p>
          {onEnable && (
            <Button onClick={onEnable} variant="primary" size="sm">
              Включить GPS
            </Button>
          )}
        </div>
      </div>
    </Card>
  );
}

export function ErrorView({
  title = 'Произошла ошибка',
  message = 'Попробуйте еще раз',
  onRetry,
}: {
  title?: string;
  message?: string;
  onRetry?: () => void;
}) {
  return (
    <div className="flex min-h-[400px] flex-col items-center justify-center p-8">
      <div className="mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-destructive/10">
        <AlertCircle className="h-10 w-10 text-destructive" />
      </div>
      <h3 className="mb-2 text-lg font-semibold">{title}</h3>
      <p className="mb-6 text-center text-sm text-muted-foreground">{message}</p>
      {onRetry && (
        <Button onClick={onRetry} variant="primary">
          Повторить
        </Button>
      )}
    </div>
  );
}

export function EmptyView({
  icon,
  title,
  message,
  action,
}: {
  icon?: React.ReactNode;
  title: string;
  message: string;
  action?: React.ReactNode;
}) {
  return (
    <div className="flex min-h-[400px] flex-col items-center justify-center p-8 text-center">
      {icon && (
        <div className="mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-muted">
          {icon}
        </div>
      )}
      <h3 className="mb-2 text-lg font-semibold">{title}</h3>
      <p className="mb-6 text-sm text-muted-foreground max-w-sm">{message}</p>
      {action}
    </div>
  );
}

export function SuccessView({
  title = 'Успешно',
  message,
  onContinue,
}: {
  title?: string;
  message?: string;
  onContinue?: () => void;
}) {
  return (
    <div className="flex min-h-[400px] flex-col items-center justify-center p-8">
      <div className="mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-success/10">
        <CheckCircle className="h-10 w-10 text-success" />
      </div>
      <h3 className="mb-2 text-lg font-semibold text-success">{title}</h3>
      {message && (
        <p className="mb-6 text-center text-sm text-muted-foreground">{message}</p>
      )}
      {onContinue && (
        <Button onClick={onContinue} variant="success">
          Продолжить
        </Button>
      )}
    </div>
  );
}

export function BackgroundTrackingActive() {
  return (
    <Card className="p-4 bg-success/5 border-success/20">
      <div className="flex items-center gap-3">
        <div className="h-3 w-3 rounded-full bg-success animate-pulse" />
        <div className="flex-1">
          <div className="font-medium text-success">Фоновый трекинг активен</div>
          <div className="text-sm text-muted-foreground">
            GPS отправляется автоматически
          </div>
        </div>
      </div>
    </Card>
  );
}

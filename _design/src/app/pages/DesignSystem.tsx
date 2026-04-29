import { useNavigate } from 'react-router';
import { ArrowLeft, Anchor, Play, CheckCircle, AlertCircle, Navigation } from 'lucide-react';
import { Button } from '../components/Button';
import { Card } from '../components/Card';
import { Badge, RaceStatusBadge } from '../components/Badge';
import { Input } from '../components/Input';
import {
  LoadingView,
  NoInternetView,
  NoGPSView,
  ErrorView,
  EmptyView,
  SuccessView,
  BackgroundTrackingActive,
} from '../components/StateViews';

export function DesignSystem() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-background pb-20">
      {/* Header */}
      <div className="bg-primary px-4 py-4 text-primary-foreground sticky top-0 z-50">
        <div className="mx-auto max-w-4xl">
          <button
            onClick={() => navigate(-1)}
            className="mb-3 flex items-center gap-2 text-primary-foreground/80"
          >
            <ArrowLeft className="h-5 w-5" />
            Назад
          </button>
          <h1 className="text-2xl font-bold">Design System</h1>
          <p className="text-sm text-primary-foreground/80">
            Компонентная система • Состояния • Цвета
          </p>
        </div>
      </div>

      <div className="mx-auto max-w-4xl px-4 py-6 space-y-8">
        {/* Colors */}
        <Section title="Цветовая палитра" subtitle="Sport-tech тема с высоким контрастом">
          <div className="grid grid-cols-2 gap-3">
            <ColorCard name="Primary" color="bg-primary" textColor="text-primary-foreground" />
            <ColorCard name="Secondary" color="bg-secondary" textColor="text-secondary-foreground" />
            <ColorCard name="Success" color="bg-success" textColor="text-success-foreground" />
            <ColorCard name="Warning" color="bg-warning" textColor="text-warning-foreground" />
            <ColorCard name="Destructive" color="bg-destructive" textColor="text-destructive-foreground" />
            <ColorCard name="Info" color="bg-info" textColor="text-info-foreground" />
          </div>

          <div className="mt-4">
            <h4 className="mb-3 text-sm font-medium text-muted-foreground">Race Status Colors</h4>
            <div className="grid grid-cols-3 gap-3">
              <ColorCard name="Planned" color="bg-race-planned" textColor="text-white" />
              <ColorCard name="Active" color="bg-race-active" textColor="text-white" />
              <ColorCard name="Finished" color="bg-race-finished" textColor="text-white" />
            </div>
          </div>
        </Section>

        {/* Typography */}
        <Section title="Типографика" subtitle="Системные шрифты, адаптированные для читаемости">
          <div className="space-y-3">
            <div>
              <p className="text-xs text-muted-foreground mb-1">Heading 1</p>
              <h1>Регата Трекер 2026</h1>
            </div>
            <div>
              <p className="text-xs text-muted-foreground mb-1">Heading 2</p>
              <h2>Активные гонки</h2>
            </div>
            <div>
              <p className="text-xs text-muted-foreground mb-1">Heading 3</p>
              <h3>Детали трассы</h3>
            </div>
            <div>
              <p className="text-xs text-muted-foreground mb-1">Body Text</p>
              <p>Обычный текст для описаний и контента</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground mb-1">Small Text</p>
              <p className="text-sm">Маленький текст для подписей</p>
            </div>
          </div>
        </Section>

        {/* Buttons */}
        <Section title="Кнопки" subtitle="Все варианты и размеры">
          <div className="space-y-4">
            <div>
              <p className="mb-2 text-xs text-muted-foreground">Variants</p>
              <div className="flex flex-wrap gap-2">
                <Button variant="primary">Primary</Button>
                <Button variant="secondary">Secondary</Button>
                <Button variant="success">Success</Button>
                <Button variant="danger">Danger</Button>
                <Button variant="ghost">Ghost</Button>
                <Button variant="outline">Outline</Button>
              </div>
            </div>

            <div>
              <p className="mb-2 text-xs text-muted-foreground">Sizes</p>
              <div className="flex flex-wrap items-end gap-2">
                <Button size="sm">Small</Button>
                <Button size="md">Medium</Button>
                <Button size="lg">Large</Button>
                <Button size="xl">Extra Large</Button>
              </div>
            </div>

            <div>
              <p className="mb-2 text-xs text-muted-foreground">States</p>
              <div className="flex flex-wrap gap-2">
                <Button>Normal</Button>
                <Button disabled>Disabled</Button>
                <Button loading>Loading</Button>
              </div>
            </div>

            <div>
              <p className="mb-2 text-xs text-muted-foreground">Full Width</p>
              <Button fullWidth variant="primary">
                <Play className="mr-2 h-5 w-5" />
                Начать гонку
              </Button>
            </div>
          </div>
        </Section>

        {/* Badges */}
        <Section title="Бейджи" subtitle="Статусы и метки">
          <div className="space-y-4">
            <div>
              <p className="mb-2 text-xs text-muted-foreground">Race Statuses</p>
              <div className="flex flex-wrap gap-2">
                <RaceStatusBadge status="planned" />
                <RaceStatusBadge status="ready" />
                <RaceStatusBadge status="active" />
                <RaceStatusBadge status="finished" />
                <RaceStatusBadge status="cancelled" />
              </div>
            </div>

            <div>
              <p className="mb-2 text-xs text-muted-foreground">Variants</p>
              <div className="flex flex-wrap gap-2">
                <Badge variant="default">Default</Badge>
                <Badge variant="success">Success</Badge>
                <Badge variant="warning">Warning</Badge>
                <Badge variant="danger">Danger</Badge>
                <Badge variant="info">Info</Badge>
              </div>
            </div>

            <div>
              <p className="mb-2 text-xs text-muted-foreground">Sizes</p>
              <div className="flex flex-wrap items-center gap-2">
                <Badge size="sm">Small</Badge>
                <Badge size="md">Medium</Badge>
                <Badge size="lg">Large</Badge>
              </div>
            </div>
          </div>
        </Section>

        {/* Cards */}
        <Section title="Карточки" subtitle="Контейнеры для контента">
          <div className="space-y-3">
            <Card>
              <h3 className="mb-1 font-semibold">Обычная карточка</h3>
              <p className="text-sm text-muted-foreground">
                Базовый контейнер с тенью и скругленными углами
              </p>
            </Card>

            <Card interactive onClick={() => alert('Clicked!')}>
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10">
                  <Anchor className="h-5 w-5 text-primary" />
                </div>
                <div className="flex-1">
                  <h3 className="font-semibold">Интерактивная карточка</h3>
                  <p className="text-sm text-muted-foreground">Нажмите для действия</p>
                </div>
              </div>
            </Card>
          </div>
        </Section>

        {/* Inputs */}
        <Section title="Поля ввода" subtitle="Формы и текстовые поля">
          <div className="space-y-3">
            <Input label="Название гонки" placeholder="Введите название" fullWidth />
            <Input
              label="Email"
              type="email"
              placeholder="your@email.ru"
              fullWidth
            />
            <Input
              label="С ошибкой"
              placeholder="Неверные данные"
              error="Это поле обязательно"
              fullWidth
            />
            <Input
              label="Отключено"
              placeholder="Недоступно"
              disabled
              fullWidth
            />
          </div>
        </Section>

        {/* State Views */}
        <Section title="Состояния экранов" subtitle="Loading, Error, Empty states">
          <div className="space-y-6">
            <Card>
              <LoadingView message="Загрузка данных..." />
            </Card>

            <Card>
              <NoInternetView onRetry={() => alert('Retry')} />
            </Card>

            <NoGPSView onEnable={() => alert('Enable GPS')} />

            <Card>
              <ErrorView
                title="Ошибка загрузки"
                message="Не удалось получить данные"
                onRetry={() => alert('Retry')}
              />
            </Card>

            <Card>
              <EmptyView
                icon={<Navigation className="h-10 w-10 text-muted-foreground" />}
                title="Нет активных гонок"
                message="У вас пока нет гонок в этом статусе"
                action={<Button>Создать гонку</Button>}
              />
            </Card>

            <Card>
              <SuccessView
                title="Гонка создана"
                message="Участники получат уведомления"
                onContinue={() => alert('Continue')}
              />
            </Card>

            <BackgroundTrackingActive />
          </div>
        </Section>

        {/* Touch Targets */}
        <Section title="Touch Targets" subtitle="Минимальные размеры для мобильных устройств">
          <Card className="p-4">
            <div className="space-y-3 text-sm">
              <div className="flex justify-between">
                <span className="text-muted-foreground">Кнопки (минимум)</span>
                <span className="font-medium">48px высота</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Поля ввода</span>
                <span className="font-medium">48px высота</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Интерактивные карточки</span>
                <span className="font-medium">Минимум 44px</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Spacing</span>
                <span className="font-medium">12px/16px grid</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Border radius</span>
                <span className="font-medium">12px</span>
              </div>
            </div>
          </Card>
        </Section>

        {/* Accessibility */}
        <Section title="Accessibility" subtitle="Требования доступности">
          <Card className="p-4">
            <div className="space-y-3 text-sm">
              <div className="flex items-start gap-2">
                <CheckCircle className="h-5 w-5 text-success flex-shrink-0 mt-0.5" />
                <span>Контраст минимум 4.5:1 для основного текста</span>
              </div>
              <div className="flex items-start gap-2">
                <CheckCircle className="h-5 w-5 text-success flex-shrink-0 mt-0.5" />
                <span>Минимальный размер шрифта 14px для мобильных</span>
              </div>
              <div className="flex items-start gap-2">
                <CheckCircle className="h-5 w-5 text-success flex-shrink-0 mt-0.5" />
                <span>Touch targets минимум 44x44px</span>
              </div>
              <div className="flex items-start gap-2">
                <CheckCircle className="h-5 w-5 text-success flex-shrink-0 mt-0.5" />
                <span>Крупные кнопки для критических действий (Start/End)</span>
              </div>
              <div className="flex items-start gap-2">
                <AlertCircle className="h-5 w-5 text-warning flex-shrink-0 mt-0.5" />
                <span>Яркие цвета для использования на солнце</span>
              </div>
            </div>
          </Card>
        </Section>
      </div>
    </div>
  );
}

function Section({
  title,
  subtitle,
  children,
}: {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
}) {
  return (
    <section>
      <div className="mb-4">
        <h2 className="text-xl font-bold">{title}</h2>
        {subtitle && <p className="text-sm text-muted-foreground">{subtitle}</p>}
      </div>
      {children}
    </section>
  );
}

function ColorCard({
  name,
  color,
  textColor,
}: {
  name: string;
  color: string;
  textColor: string;
}) {
  return (
    <div className={`${color} ${textColor} rounded-lg p-4`}>
      <div className="font-semibold">{name}</div>
      <div className="text-sm opacity-80">{color}</div>
    </div>
  );
}

# Справочник компонентов

## Базовые компоненты

### Button

**Путь**: `src/app/components/Button.tsx`

**Использование**:
```tsx
<Button
  variant="primary"
  size="lg"
  fullWidth
  loading={false}
  disabled={false}
  onClick={() => {}}
>
  Начать гонку
</Button>
```

**Props**:
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `'primary' \| 'secondary' \| 'success' \| 'danger' \| 'ghost' \| 'outline'` | `'primary'` | Визуальный стиль |
| `size` | `'sm' \| 'md' \| 'lg' \| 'xl'` | `'md'` | Размер кнопки |
| `fullWidth` | `boolean` | `false` | Растянуть на всю ширину |
| `loading` | `boolean` | `false` | Показать спиннер |
| `disabled` | `boolean` | `false` | Отключить кнопку |
| `children` | `ReactNode` | required | Содержимое |
| `onClick` | `() => void` | - | Обработчик клика |

**Варианты**:

```tsx
// Primary - основные действия
<Button variant="primary">Сохранить</Button>

// Success - подтверждения
<Button variant="success">Принять</Button>

// Danger - опасные действия
<Button variant="danger">Удалить</Button>

// Outline - вторичные с рамкой
<Button variant="outline">Отмена</Button>
```

**Размеры**:
- `sm`: 40px высота - для компактных UI
- `md`: 48px высота - стандарт
- `lg`: 56px высота - заметные действия
- `xl`: 64px высота - критические действия (Start/End race)

**С иконками**:
```tsx
<Button variant="primary">
  <Play className="mr-2 h-5 w-5" />
  Начать гонку
</Button>
```

---

### Card

**Путь**: `src/app/components/Card.tsx`

**Использование**:
```tsx
<Card 
  interactive
  onClick={() => navigate('/race/123')}
  className="custom-class"
>
  <h3>Весенний Кубок</h3>
  <p>W/L трасса</p>
</Card>
```

**Props**:
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `children` | `ReactNode` | required | Содержимое карточки |
| `className` | `string` | - | Дополнительные классы |
| `onClick` | `() => void` | - | Обработчик клика |
| `interactive` | `boolean` | `false` | Добавить hover/active эффекты |

**Стили**:
- Border radius: 12px
- Padding: 16px (1rem)
- Shadow: subtle (shadow-sm)
- Border: тонкая, цвет border
- Background: card (белый)

**Примеры использования**:

```tsx
// Обычная карточка
<Card>
  <h3>Заголовок</h3>
  <p>Контент</p>
</Card>

// Кликабельная карточка
<Card interactive onClick={handleClick}>
  <RaceInfo />
</Card>

// С кастомным фоном
<Card className="bg-success/10 border-success/20">
  <SuccessMessage />
</Card>
```

---

### Badge

**Путь**: `src/app/components/Badge.tsx`

**Использование**:
```tsx
<Badge variant="success" size="md">
  Активна
</Badge>
```

**Props**:
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `children` | `ReactNode` | required | Текст бейджа |
| `variant` | `'default' \| 'success' \| 'warning' \| 'danger' \| 'info' \| 'planned' \| 'active' \| 'finished'` | `'default'` | Цветовая схема |
| `size` | `'sm' \| 'md' \| 'lg'` | `'md'` | Размер |
| `className` | `string` | - | Доп. классы |

**Специализированный компонент RaceStatusBadge**:

```tsx
<RaceStatusBadge status="active" />
// Автоматически выбирает цвет и текст
```

**Маппинг статусов**:
| Status | Label | Color |
|--------|-------|-------|
| `planned` | Запланирована | Purple |
| `ready` | Готова к старту | Blue |
| `active` | В процессе | Green |
| `finished` | Завершена | Gray |
| `cancelled` | Отменена | Red |

---

### Input

**Путь**: `src/app/components/Input.tsx`

**Использование**:
```tsx
<Input
  label="Email"
  type="email"
  placeholder="your@email.ru"
  value={email}
  onChange={(e) => setEmail(e.target.value)}
  error={errors.email}
  fullWidth
/>
```

**Props**:
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `label` | `string` | - | Подпись поля |
| `error` | `string` | - | Текст ошибки |
| `fullWidth` | `boolean` | `false` | На всю ширину |
| `type` | `string` | `'text'` | HTML input type |
| `placeholder` | `string` | - | Placeholder |
| `value` | `string` | - | Значение |
| `onChange` | `(e) => void` | - | Обработчик изменения |
| `disabled` | `boolean` | `false` | Отключить |

**Стили**:
- Height: 48px минимум
- Border radius: 12px
- Focus: синяя ring (2px)
- Error: красная border

**Состояния**:

```tsx
// Нормальное
<Input label="Название" />

// С ошибкой
<Input 
  label="Email" 
  error="Неверный формат email"
/>

// Отключенное
<Input 
  label="Недоступно" 
  disabled 
/>
```

---

## State View Компоненты

**Путь**: `src/app/components/StateViews.tsx`

### LoadingView

```tsx
<LoadingView message="Загрузка гонок..." />
```

**Props**:
| Prop | Type | Default |
|------|------|---------|
| `message` | `string` | `'Загрузка...'` |

**Когда использовать**:
- Загрузка данных с сервера
- Ожидание ответа API
- Инициализация экрана

---

### NoInternetView

```tsx
<NoInternetView onRetry={() => fetchData()} />
```

**Props**:
| Prop | Type | Default |
|------|------|---------|
| `onRetry` | `() => void` | - |

**Когда использовать**:
- Нет подключения к интернету
- Timeout запросов
- Offline mode

---

### NoGPSView

```tsx
<NoGPSView onEnable={() => requestGPSPermission()} />
```

**Props**:
| Prop | Type | Default |
|------|------|---------|
| `onEnable` | `() => void` | - |

**Когда использовать**:
- GPS выключен
- Нет разрешения на геолокацию
- Перед началом гонки (проверка)

---

### ErrorView

```tsx
<ErrorView
  title="Ошибка загрузки"
  message="Не удалось получить список гонок"
  onRetry={() => fetchRaces()}
/>
```

**Props**:
| Prop | Type | Default |
|------|------|---------|
| `title` | `string` | `'Произошла ошибка'` |
| `message` | `string` | `'Попробуйте еще раз'` |
| `onRetry` | `() => void` | - |

---

### EmptyView

```tsx
<EmptyView
  icon={<Calendar className="h-10 w-10" />}
  title="Нет гонок"
  message="Вы пока не участвуете ни в одной гонке"
  action={<Button>Создать гонку</Button>}
/>
```

**Props**:
| Prop | Type | Default |
|------|------|---------|
| `icon` | `ReactNode` | - |
| `title` | `string` | required |
| `message` | `string` | required |
| `action` | `ReactNode` | - |

---

### SuccessView

```tsx
<SuccessView
  title="Гонка создана"
  message="Участники получат уведомления"
  onContinue={() => navigate('/judge')}
/>
```

---

### BackgroundTrackingActive

```tsx
<BackgroundTrackingActive />
```

Компактный индикатор активного фонового трекинга.

---

## Составные компоненты (примеры)

### RaceCard (для списков)

**Структура**:
```tsx
<Card interactive onClick={() => navigate(`/race/${race.id}`)}>
  <div className="space-y-3">
    {/* Header */}
    <div className="flex items-start justify-between gap-3">
      <div className="flex-1 min-w-0">
        <h3 className="font-semibold truncate">{race.name}</h3>
        <p className="text-sm text-muted-foreground">
          {race.course?.name}
        </p>
      </div>
      <RaceStatusBadge status={race.status} />
    </div>

    {/* Info */}
    <div className="flex items-center justify-between text-sm">
      <div className="text-muted-foreground">
        <Calendar className="inline h-4 w-4 mr-1" />
        {formatTime(race.scheduledStart)}
      </div>
      <div className="font-medium">
        {race.participants.length} участников
      </div>
    </div>
  </div>
</Card>
```

**Используется в**:
- JudgeDashboard
- ParticipantDashboard

---

### ParticipantRow (в списке участников)

```tsx
<div className="flex items-center justify-between rounded-lg bg-secondary p-3">
  <div className="flex-1">
    <div className="font-medium">{participant.userName}</div>
    <div className="text-sm text-muted-foreground">
      {participant.boatName} • {participant.sailNumber}
    </div>
  </div>
  <Badge variant="success" size="sm">
    {participant.position} место
  </Badge>
</div>
```

---

## Утилитные функции

**Путь**: `src/app/utils.ts`

### cn (className merger)

```tsx
import { cn } from '../utils';

<div className={cn(
  'base-class',
  condition && 'conditional-class',
  'another-class'
)} />
```

Объединяет классы с поддержкой условий.

---

### formatTime

```tsx
import { formatTime } from '../utils';

formatTime('2026-04-13T14:05:12Z')
// → "14:05"
```

Форматирует дату в HH:MM (24-часовой формат).

---

### formatDate

```tsx
import { formatDate } from '../utils';

formatDate('2026-04-13T14:05:12Z')
// → "13 апреля 2026"
```

---

### formatDateTime

```tsx
import { formatDateTime } from '../utils';

formatDateTime('2026-04-13T14:05:12Z')
// → "13 апреля 2026 14:05"
```

---

### calculateDuration

```tsx
import { calculateDuration } from '../utils';

calculateDuration(startTime, endTime)
// → "15м 32с"
// или "1ч 5м 12с"
```

Вычисляет разницу между двумя датами и форматирует в читаемый вид.

---

## Иконки (Lucide React)

**Установлен**: `lucide-react`

**Частые иконки**:

```tsx
import {
  Anchor,      // Логотип приложения, навигация
  Play,        // Старт гонки
  Square,      // Стоп гонки
  CheckCircle, // Success
  AlertCircle, // Error/Warning
  Calendar,    // Дата/время
  Clock,       // Время
  Navigation,  // GPS
  MapPin,      // Местоположение
  Users,       // Участники
  Settings,    // Настройки
  ArrowLeft,   // Назад
  Plus,        // Добавить
  Trash2,      // Удалить
  Save,        // Сохранить
  WifiOff,     // Нет интернета
  Battery,     // Батарея
  Bell,        // Уведомления
  LogOut,      // Выход
  User,        // Профиль
  Map,         // Карта
  Activity,    // Активность/трекинг
} from 'lucide-react';
```

**Использование**:

```tsx
<Button>
  <Play className="mr-2 h-5 w-5" />
  Начать
</Button>

// Размеры:
className="h-4 w-4"  // Small (16px)
className="h-5 w-5"  // Medium (20px)
className="h-6 w-6"  // Large (24px)
className="h-8 w-8"  // XL (32px)
```

---

## Анимации (Motion)

**Установлен**: `motion/react`

**Базовые анимации**:

```tsx
import { motion } from 'motion/react';

// Fade in
<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  transition={{ duration: 0.3 }}
>
  Content
</motion.div>

// Slide in
<motion.div
  initial={{ x: -20, opacity: 0 }}
  animate={{ x: 0, opacity: 1 }}
  transition={{ duration: 0.2 }}
>
  Content
</motion.div>

// Scale on tap
<motion.button
  whileTap={{ scale: 0.95 }}
>
  Button
</motion.button>
```

**Где использовать**:
- Переходы между экранами
- Появление карточек
- Нажатие кнопок (scale)
- Модальные окна

---

## Карта (Leaflet)

**Установлено**: 
- `leaflet`
- `react-leaflet`

**Базовое использование**:

```tsx
import { MapContainer, TileLayer, Marker, Polyline } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

<MapContainer
  center={[59.9311, 30.3609]}
  zoom={14}
  className="h-full w-full"
>
  <TileLayer
    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
  />
  
  <Marker position={[59.9311, 30.3609]} />
  
  <Polyline
    positions={[[59.93, 30.36], [59.94, 30.37]]}
    pathOptions={{ color: 'blue', weight: 3 }}
  />
</MapContainer>
```

**Кастомные маркеры**:

```tsx
import L from 'leaflet';

const icon = L.divIcon({
  className: 'custom-marker',
  html: `<div style="
    width: 24px;
    height: 24px;
    background: #10b981;
    border: 3px solid white;
    border-radius: 50%;
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
  "></div>`,
  iconSize: [24, 24],
  iconAnchor: [12, 12],
});

<Marker position={point} icon={icon} />
```

**Обработка кликов**:

```tsx
function MapClickHandler({ onMapClick }) {
  useMapEvents({
    click: (e) => {
      onMapClick(e.latlng.lat, e.latlng.lng);
    },
  });
  return null;
}

<MapContainer>
  <MapClickHandler onMapClick={handleClick} />
</MapContainer>
```

---

## Типы данных

**Путь**: `src/app/types.ts`

### Race

```typescript
interface Race {
  id: string;
  name: string;
  status: RaceStatus;
  courseId?: string;
  course?: Course;
  judgeId: string;
  judgeName: string;
  scheduledStart?: string;
  actualStart?: string;
  actualEnd?: string;
  participants: Participant[];
  trackingInterval: number;
  createdAt: string;
}
```

### Course

```typescript
interface Course {
  id: string;
  name: string;
  raceType: RaceType;
  points: CoursePoint[];
  windDirection?: number;
  validated: boolean;
  validationErrors?: string[];
}
```

### CoursePoint

```typescript
interface CoursePoint {
  id: string;
  type: CoursePointType;
  lat: number;
  lng: number;
  order: number;
  name?: string;
}

type CoursePointType = 
  | 'start-line' 
  | 'finish-line' 
  | 'mark' 
  | 'gate-left' 
  | 'gate-right' 
  | 'offset-mark';
```

### Participant

```typescript
interface Participant {
  id: string;
  userId: string;
  userName: string;
  boatName?: string;
  sailNumber?: string;
  status: 'invited' | 'confirmed' | 'racing' | 'finished' | 'dnf';
  finishTime?: string;
  position?: number;
}
```

---

## Mock Data

**Путь**: `src/app/mockData.ts`

Доступные моки:
- `mockJudge` - пользователь-судья
- `mockParticipant` - пользователь-участник
- `mockCourses` - массив трасс (2 штуки)
- `mockRaces` - массив гонок (4 штуки)

**Использование**:

```tsx
import { mockRaces, mockJudge } from '../mockData';

// Получить активные гонки
const activeRaces = mockRaces.filter(r => r.status === 'active');
```

---

## Tailwind CSS классы

### Spacing
```
p-4    // padding: 16px
px-4   // padding left/right: 16px
py-3   // padding top/bottom: 12px
gap-3  // gap: 12px
space-y-4  // margin-top для детей: 16px
```

### Colors
```
bg-primary
bg-success
bg-warning
bg-destructive
text-primary
text-muted-foreground
border-border
```

### Layout
```
flex
flex-col
items-center
justify-between
grid grid-cols-2
max-w-2xl
w-full
h-screen
```

### Typography
```
text-sm   // 14px
text-base // 16px
text-lg   // 18px
text-xl   // 20px
text-2xl  // 24px
font-medium
font-semibold
font-bold
```

### Effects
```
rounded-lg     // 12px
rounded-full   // 50%
shadow-sm
shadow-md
opacity-50
hover:bg-secondary
active:scale-95
```

---

## Checklist для Flutter реализации

### Компоненты
- [ ] Button (все варианты и размеры)
- [ ] Card (обычная и interactive)
- [ ] Badge (все варианты)
- [ ] Input (с label, error, disabled)
- [ ] LoadingView
- [ ] NoInternetView
- [ ] NoGPSView
- [ ] ErrorView
- [ ] EmptyView
- [ ] SuccessView

### Утилиты
- [ ] formatTime
- [ ] formatDate
- [ ] formatDateTime
- [ ] calculateDuration
- [ ] className merger (если нужен)

### Экраны
- [ ] RoleSelect
- [ ] Login / Register
- [ ] JudgeDashboard
- [ ] CreateRace
- [ ] CourseBuilder (с картой)
- [ ] RaceDetails
- [ ] ParticipantDashboard
- [ ] RaceView
- [ ] RacingMode (hands-free)
- [ ] Settings

### Интеграции
- [ ] OpenStreetMap (Leaflet аналог для Flutter)
- [ ] GPS permissions
- [ ] Background tracking
- [ ] Push notifications
- [ ] Offline storage
- [ ] API integration

### Тестирование
- [ ] Все состояния кнопок
- [ ] Error states
- [ ] Loading states
- [ ] Empty states
- [ ] GPS on/off
- [ ] Internet on/off
- [ ] Различные размеры экранов
- [ ] На солнце (яркость)
- [ ] Мокрые руки (крупные targets)

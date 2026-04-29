import { ReactNode } from 'react';
import { cn } from '../utils';
import type { RaceStatus } from '../types';

interface BadgeProps {
  children: ReactNode;
  variant?: 'default' | 'success' | 'warning' | 'danger' | 'info' | 'planned' | 'active' | 'finished';
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export function Badge({ children, variant = 'default', size = 'md', className }: BadgeProps) {
  const variants = {
    default: 'bg-muted text-muted-foreground',
    success: 'bg-success text-success-foreground',
    warning: 'bg-warning text-warning-foreground',
    danger: 'bg-destructive text-destructive-foreground',
    info: 'bg-info text-info-foreground',
    planned: 'bg-race-planned text-white',
    active: 'bg-race-active text-white',
    finished: 'bg-race-finished text-white',
  };

  const sizes = {
    sm: 'px-2 py-1 text-xs',
    md: 'px-3 py-1.5 text-sm',
    lg: 'px-4 py-2 text-base',
  };

  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full font-medium whitespace-nowrap',
        variants[variant],
        sizes[size],
        className
      )}
    >
      {children}
    </span>
  );
}

export function RaceStatusBadge({ status }: { status: RaceStatus }) {
  const statusConfig = {
    planned: { label: 'Запланирована', variant: 'planned' as const },
    ready: { label: 'Готова к старту', variant: 'info' as const },
    active: { label: 'В процессе', variant: 'active' as const },
    finished: { label: 'Завершена', variant: 'finished' as const },
    cancelled: { label: 'Отменена', variant: 'danger' as const },
  };

  const config = statusConfig[status];

  return <Badge variant={config.variant}>{config.label}</Badge>;
}

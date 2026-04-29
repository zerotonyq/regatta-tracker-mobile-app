import { ReactNode } from 'react';
import { cn } from '../utils';

interface CardProps {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
  interactive?: boolean;
}

export function Card({ children, className, onClick, interactive }: CardProps) {
  return (
    <div
      className={cn(
        'rounded-xl bg-card p-4 shadow-sm border border-border',
        interactive && 'cursor-pointer transition-all active:scale-[0.98] hover:shadow-md',
        className
      )}
      onClick={onClick}
    >
      {children}
    </div>
  );
}

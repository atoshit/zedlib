export type NotificationType = 'success' | 'error' | 'warning' | 'info';
export type NotificationPosition = 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left' | 'top-center';

export interface NotificationData {
  id: string;
  type: NotificationType;
  title: string;
  subtitle?: string;
  message?: string;
  duration?: number;
  icon?: string;
  image?: string;
  color?: string;
  position?: NotificationPosition;
  showProgress?: boolean;
  count?: number;
}

export interface NotificationConfig {
  defaultDuration: number;
  maxVisible: number;
  position: NotificationPosition;
  stackDirection: 'up' | 'down';
}

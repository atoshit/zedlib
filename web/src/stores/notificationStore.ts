import { create } from 'zustand';
import type { NotificationData, NotificationConfig, NotificationType } from '@/types';

interface NotificationStore {
  notifications: NotificationData[];
  config: NotificationConfig;

  addNotification: (notification: Omit<NotificationData, 'id'>) => string;
  removeNotification: (id: string) => void;
  clearAll: () => void;
  updateConfig: (config: Partial<NotificationConfig>) => void;
  notify: (type: NotificationType, title: string, message?: string, duration?: number) => string;
}

let notifCounter = 0;

export const useNotificationStore = create<NotificationStore>((set, get) => ({
  notifications: [],
  config: {
    defaultDuration: 5000,
    maxVisible: 5,
    position: 'bottom-left',
    stackDirection: 'down',
  },

  addNotification: (notification) => {
    const id = `notif_${++notifCounter}`;
    const fullNotification: NotificationData = {
      id,
      duration: get().config.defaultDuration,
      position: get().config.position,
      showProgress: true,
      ...notification,
    };

    set((state) => {
      const updated = [...state.notifications, fullNotification];
      if (updated.length > state.config.maxVisible) {
        return { notifications: updated.slice(-state.config.maxVisible) };
      }
      return { notifications: updated };
    });

    if (fullNotification.duration && fullNotification.duration > 0) {
      setTimeout(() => {
        get().removeNotification(id);
      }, fullNotification.duration);
    }

    return id;
  },

  removeNotification: (id) => {
    set((state) => ({
      notifications: state.notifications.filter((n) => n.id !== id),
    }));
  },

  clearAll: () => {
    set({ notifications: [] });
  },

  updateConfig: (config) => {
    set((state) => ({
      config: { ...state.config, ...config },
    }));
  },

  notify: (type, title, message, duration) => {
    return get().addNotification({ type, title, message, duration });
  },
}));

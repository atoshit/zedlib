import { create } from 'zustand';
import type { NotificationData, NotificationConfig, NotificationType } from '@/types';

interface NotificationStore {
  notifications: NotificationData[];
  config: NotificationConfig;
  timers: Record<string, ReturnType<typeof setTimeout>>;

  addNotification: (notification: Omit<NotificationData, 'id'>) => string;
  removeNotification: (id: string) => void;
  clearAll: () => void;
  updateConfig: (config: Partial<NotificationConfig>) => void;
  notify: (type: NotificationType, title: string, message?: string, duration?: number) => string;
}

let notifCounter = 0;

function isSameNotification(a: Omit<NotificationData, 'id' | 'count'>, b: NotificationData): boolean {
  return a.type === b.type && a.title === b.title && (a.subtitle ?? '') === (b.subtitle ?? '') && (a.message ?? '') === (b.message ?? '');
}

export const useNotificationStore = create<NotificationStore>((set, get) => ({
  notifications: [],
  config: {
    defaultDuration: 5000,
    maxVisible: 5,
    position: 'bottom-left',
    stackDirection: 'down',
  },
  timers: {},

  addNotification: (notification) => {
    const state = get();
    const existing = state.notifications.find((n) => isSameNotification(notification, n));

    if (existing) {
      const newCount = (existing.count ?? 1) + 1;
      const duration = notification.duration ?? state.config.defaultDuration;

      set((s) => ({
        notifications: s.notifications.map((n) =>
          n.id === existing.id ? { ...n, count: newCount } : n
        ),
      }));

      if (state.timers[existing.id]) {
        clearTimeout(state.timers[existing.id]);
      }

      if (duration > 0) {
        const timer = setTimeout(() => {
          get().removeNotification(existing.id);
        }, duration);
        set((s) => ({ timers: { ...s.timers, [existing.id]: timer } }));
      }

      return existing.id;
    }

    const id = `notif_${++notifCounter}`;
    const fullNotification: NotificationData = {
      id,
      duration: state.config.defaultDuration,
      position: state.config.position,
      showProgress: true,
      count: 1,
      ...notification,
    };

    set((s) => {
      const updated = [...s.notifications, fullNotification];
      if (updated.length > s.config.maxVisible) {
        return { notifications: updated.slice(-s.config.maxVisible) };
      }
      return { notifications: updated };
    });

    if (fullNotification.duration && fullNotification.duration > 0) {
      const timer = setTimeout(() => {
        get().removeNotification(id);
      }, fullNotification.duration);
      set((s) => ({ timers: { ...s.timers, [id]: timer } }));
    }

    return id;
  },

  removeNotification: (id) => {
    const state = get();
    if (state.timers[id]) {
      clearTimeout(state.timers[id]);
    }
    set((s) => {
      const { [id]: _, ...rest } = s.timers;
      return {
        notifications: s.notifications.filter((n) => n.id !== id),
        timers: rest,
      };
    });
  },

  clearAll: () => {
    const state = get();
    Object.values(state.timers).forEach(clearTimeout);
    set({ notifications: [], timers: {} });
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

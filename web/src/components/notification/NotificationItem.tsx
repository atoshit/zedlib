import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import type { NotificationData } from '@/types';
import { useNotificationStore } from '@/stores';

interface NotificationItemProps {
  notification: NotificationData;
}

const typeStyles: Record<string, { border: string; icon: string; iconColor: string }> = {
  success: {
    border: 'border-emerald-500/30',
    icon: 'fa-solid fa-check',
    iconColor: 'text-emerald-400',
  },
  error: {
    border: 'border-red-500/30',
    icon: 'fa-solid fa-xmark',
    iconColor: 'text-red-400',
  },
  warning: {
    border: 'border-amber-500/30',
    icon: 'fa-solid fa-triangle-exclamation',
    iconColor: 'text-amber-400',
  },
  info: {
    border: 'border-blue-500/30',
    icon: 'fa-solid fa-circle-info',
    iconColor: 'text-blue-400',
  },
};

export function NotificationItem({ notification }: NotificationItemProps) {
  const removeNotification = useNotificationStore((s) => s.removeNotification);
  const [progress, setProgress] = useState(100);
  const style = typeStyles[notification.type] ?? typeStyles.info;
  const duration = notification.duration ?? 5000;

  useEffect(() => {
    if (!notification.showProgress || duration <= 0) return;

    const interval = 50;
    const step = (interval / duration) * 100;
    const timer = setInterval(() => {
      setProgress((prev) => {
        const next = prev - step;
        return next <= 0 ? 0 : next;
      });
    }, interval);

    return () => clearInterval(timer);
  }, [duration, notification.showProgress]);

  return (
    <motion.div
      layout
      initial={{ opacity: 0, x: 60, scale: 0.95 }}
      animate={{ opacity: 1, x: 0, scale: 1 }}
      exit={{ opacity: 0, x: 60, scale: 0.95 }}
      transition={{ type: 'spring', stiffness: 400, damping: 30 }}
      className={`
        relative w-[320px] rounded-lg border overflow-hidden
        ${style.border}
        bg-black/70 shadow-xl shadow-black/40
      `}
    >
      <div className="flex items-start gap-3 px-4 py-3">
        <i className={`${notification.icon ? `fa-solid fa-${notification.icon}` : style.icon} text-base mt-0.5 ${style.iconColor}`} />
        <div className="flex-1 min-w-0">
          <p className="text-[13px] font-semibold text-white">{notification.title}</p>
          {notification.message && (
            <p className="text-[11px] text-white/70 mt-0.5 leading-relaxed">
              {notification.message}
            </p>
          )}
        </div>
        <button
          onClick={() => removeNotification(notification.id)}
          className="text-white/30 hover:text-white transition-colors p-0.5"
        >
          <i className="fa-solid fa-xmark text-xs" />
        </button>
      </div>
      {notification.showProgress && duration > 0 && (
        <div className="h-[2px] bg-white/5">
          <motion.div
            className={`h-full ${
              notification.type === 'success'
                ? 'bg-emerald-400'
                : notification.type === 'error'
                  ? 'bg-red-400'
                  : notification.type === 'warning'
                    ? 'bg-amber-400'
                    : 'bg-blue-400'
            }`}
            style={{ width: `${progress}%` }}
            transition={{ duration: 0.05, ease: 'linear' }}
          />
        </div>
      )}
    </motion.div>
  );
}

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import type { NotificationData } from '@/types';
import { useNotificationStore } from '@/stores';

interface NotificationItemProps {
  notification: NotificationData;
}

const typeConfig: Record<string, { color: string; icon: string }> = {
  success: { color: '#22c55e', icon: 'check' },
  error: { color: '#ef4444', icon: 'xmark' },
  warning: { color: '#f59e0b', icon: 'triangle-exclamation' },
  info: { color: '#3b82f6', icon: 'circle-info' },
};

export function NotificationItem({ notification }: NotificationItemProps) {
  const removeNotification = useNotificationStore((s) => s.removeNotification);
  const [progress, setProgress] = useState(100);
  const config = typeConfig[notification.type] ?? typeConfig.info;
  const accentColor = notification.color || config.color;
  const iconName = notification.icon || config.icon;
  const duration = notification.duration ?? 5000;

  useEffect(() => {
    if (!notification.showProgress || duration <= 0) return;

    const interval = 50;
    const step = (interval / duration) * 100;
    const timer = setInterval(() => {
      setProgress((prev) => Math.max(0, prev - step));
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
      className="notification-shine relative w-[320px] rounded-lg overflow-hidden bg-black/70"
      style={{
        borderLeft: `3px solid ${accentColor}`,
        boxShadow: `0 0 20px ${accentColor}15, 0 25px 50px -12px rgba(0,0,0,0.5)`,
      }}
    >
      <div className="flex items-start gap-3 px-4 py-3">
        <div
          className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
          style={{ backgroundColor: `${accentColor}20` }}
        >
          <i className={`fa-solid fa-${iconName} text-sm`} style={{ color: accentColor }} />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-[13px] font-semibold text-white">{notification.title}</p>
          {notification.message && (
            <p className="text-[11px] text-white/60 mt-0.5 leading-relaxed">
              {notification.message}
            </p>
          )}
        </div>
        <button
          onClick={() => removeNotification(notification.id)}
          className="text-white/20 hover:text-white/50 transition-colors p-0.5"
        >
          <i className="fa-solid fa-xmark text-xs" />
        </button>
      </div>
      {notification.showProgress && duration > 0 && (
        <div className="h-[2px] bg-white/5">
          <motion.div
            className="h-full rounded-full"
            style={{ width: `${progress}%`, backgroundColor: accentColor }}
            transition={{ duration: 0.05, ease: 'linear' }}
          />
        </div>
      )}
    </motion.div>
  );
}

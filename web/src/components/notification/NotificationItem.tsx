import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import type { NotificationData } from '@/types';

interface NotificationItemProps {
  notification: NotificationData;
}

const typeConfig: Record<string, { icon: string }> = {
  success: { icon: 'circle-check' },
  error: { icon: 'circle-xmark' },
  warning: { icon: 'triangle-exclamation' },
  info: { icon: 'circle-info' },
};

const IMAGE_SIZE = 56;
const NOTIF_WIDTH = 278;
const NOTIF_ACCENT_COLOR = '#ef4444'; // Rouge pour tout (barre, icône) ; seul l'icône change selon le type

export function NotificationItem({ notification }: NotificationItemProps) {
  const [progress, setProgress] = useState(100);
  const config = typeConfig[notification.type] ?? typeConfig.info;
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
      initial={{ opacity: 0, x: -NOTIF_WIDTH }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -NOTIF_WIDTH }}
      transition={{ type: 'spring', stiffness: 400, damping: 30 }}
      className="notification-item relative min-h-[95px] rounded-lg overflow-hidden bg-black/70 flex flex-col"
      style={{
        width: NOTIF_WIDTH,
        boxShadow: '0 25px 50px -12px rgba(0,0,0,0.5)',
      }}
    >
      <div className="flex flex-row flex-shrink-0">
        {/* Image: coin supérieur gauche, collé aux bords (affichée seulement si définie) */}
        {notification.image && (
          <div
            className="flex-shrink-0 rounded-tl-lg overflow-hidden"
            style={{ width: IMAGE_SIZE, height: IMAGE_SIZE }}
          >
            <img
              src={notification.image}
              alt=""
              className="w-full h-full object-cover"
            />
          </div>
        )}

        {/* Titre et sous-titre : à droite de l'image si image, sinon en haut à gauche */}
        <div
          className={`flex-1 min-w-0 pt-1.5 pr-2.5 pb-1 flex flex-col text-left ${!notification.image ? 'pl-2.5' : 'pl-2'}`}
        >
          <div className="flex items-start justify-between gap-1.5">
            <p className="text-[19px] font-bold text-white leading-tight flex-1 min-w-0">
              {notification.title}
            </p>
            <div
              className="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0"
              style={{ backgroundColor: `${NOTIF_ACCENT_COLOR}25` }}
            >
              <i
                className={`fa-solid fa-${iconName} text-xs`}
                style={{ color: NOTIF_ACCENT_COLOR }}
              />
            </div>
          </div>

          {notification.subtitle && (
            <p className="text-[13px] text-white/60 mt-0.5 leading-tight">
              {notification.subtitle}
            </p>
          )}
        </div>
      </div>

      {/* Message: pleine largeur, part de la gauche */}
      {notification.message && (
        <div className="px-2.5 pb-1 pt-1.5 flex-shrink-0">
          <p className="text-[13px] text-white/90 leading-relaxed">
            {notification.message}
          </p>
        </div>
      )}

      {/* Espace réservé en bas quand la barre est affichée, pour ne pas que le contenu passe sous la barre */}
      {notification.showProgress && duration > 0 && (
        <div className="flex-shrink-0 h-1" aria-hidden />
      )}

      {/* Barre de progression en position absolue, collée au bord du bas */}
      {notification.showProgress && duration > 0 && (
        <div
          className="absolute bottom-0 left-0 right-0 h-1 bg-white/10 rounded-b-lg overflow-hidden"
        >
          <motion.div
            className="h-full rounded-r"
            style={{
              width: `${progress}%`,
              backgroundColor: NOTIF_ACCENT_COLOR,
            }}
            transition={{ duration: 0.05, ease: 'linear' }}
          />
        </div>
      )}
    </motion.div>
  );
}

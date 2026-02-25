import { AnimatePresence } from 'framer-motion';
import { useNotificationStore } from '@/stores';
import { NotificationItem } from './NotificationItem';

const positionClasses: Record<string, string> = {
  'top-right': 'top-4 right-4',
  'top-left': 'top-4 left-4',
  'bottom-right': 'bottom-4 right-4',
  'bottom-left': 'bottom-4 left-4',
  'top-center': 'top-4 left-1/2 -translate-x-1/2',
};

export function NotificationContainer() {
  const notifications = useNotificationStore((s) => s.notifications);
  const position = useNotificationStore((s) => s.config.position);

  return (
    <div className={`fixed z-[100] flex flex-col gap-2 ${positionClasses[position] ?? positionClasses['top-right']}`}>
      <AnimatePresence mode="popLayout">
        {notifications.map((notif) => (
          <NotificationItem key={notif.id} notification={notif} />
        ))}
      </AnimatePresence>
    </div>
  );
}

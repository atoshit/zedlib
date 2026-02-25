import { useNotificationStore } from '@/stores';
import type { NotificationType } from '@/types';

const testNotifications: { type: NotificationType; title: string; message: string }[] = [
  { type: 'success', title: 'Opération réussie', message: 'Le véhicule a été spawné avec succès.' },
  { type: 'error', title: 'Erreur', message: 'Impossible de spawner le véhicule.' },
  { type: 'warning', title: 'Attention', message: 'Vous approchez de la limite de véhicules.' },
  { type: 'info', title: 'Information', message: 'Un nouveau joueur a rejoint le serveur.' },
];

export function NotificationTester() {
  const { notify, clearAll, notifications } = useNotificationStore();

  return (
    <div className="space-y-3">
      <p className="text-[11px] text-zed-text-dim">
        Test des différents types de notifications.
      </p>

      <div className="grid grid-cols-2 gap-2">
        {testNotifications.map((notif) => (
          <button
            key={notif.type}
            onClick={() => notify(notif.type, notif.title, notif.message)}
            className={`
              rounded-lg px-3 py-2 text-[11px] font-medium border transition-all
              ${notif.type === 'success' ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-400 hover:bg-emerald-500/20' : ''}
              ${notif.type === 'error' ? 'bg-red-500/10 border-red-500/20 text-red-400 hover:bg-red-500/20' : ''}
              ${notif.type === 'warning' ? 'bg-amber-500/10 border-amber-500/20 text-amber-400 hover:bg-amber-500/20' : ''}
              ${notif.type === 'info' ? 'bg-blue-500/10 border-blue-500/20 text-blue-400 hover:bg-blue-500/20' : ''}
            `}
          >
            {notif.type.charAt(0).toUpperCase() + notif.type.slice(1)}
          </button>
        ))}
      </div>

      <button
        onClick={() => notify('success', 'Custom', 'Notification personnalisée !', 10000)}
        className="w-full bg-zed-accent/10 hover:bg-zed-accent/20 text-zed-accent border border-zed-accent/20 rounded-lg px-3 py-2 text-[12px] font-medium transition-all"
      >
        Notification longue (10s)
      </button>

      <button
        onClick={clearAll}
        className="w-full bg-zed-elevated hover:bg-zed-border/50 text-zed-text-muted border border-zed-border/40 rounded-lg px-3 py-2 text-[12px] font-medium transition-all"
      >
        Tout effacer
      </button>

      <div className="bg-zed-bg/50 rounded-lg p-3 border border-zed-border/20">
        <p className="text-[10px] text-zed-text-dim">
          <span className="text-zed-accent">Actives :</span> {notifications.length}
        </p>
      </div>
    </div>
  );
}

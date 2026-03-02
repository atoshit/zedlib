import { useEffect, useState, useCallback } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { useProgressBarStore, useConfigStore } from '@/stores';
import { nuiCallback } from '@/nui';

export function ProgressBar() {
  const { active, data, startTime } = useProgressBarStore();
  const accentColor = useConfigStore((s) => s.config.accentColor);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    if (!active || !data) {
      setProgress(0);
      return;
    }

    const interval = 16;
    const timer = setInterval(() => {
      const elapsed = Date.now() - startTime;
      const pct = Math.min((elapsed / data.duration) * 100, 100);
      setProgress(pct);

      if (pct >= 100) {
        clearInterval(timer);
        nuiCallback('zedlib:progressComplete', { cancelled: false });
      }
    }, interval);

    return () => clearInterval(timer);
  }, [active, data, startTime]);

  const handleCancel = useCallback(() => {
    if (!data?.canCancel) return;
    nuiCallback('zedlib:progressComplete', { cancelled: true });
  }, [data]);

  useEffect(() => {
    if (!active || !data?.canCancel) return;

    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        handleCancel();
      }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [active, data, handleCancel]);

  return (
    <AnimatePresence>
      {active && data && (
        <motion.div
          className="fixed bottom-[6%] left-0 right-0 flex justify-center z-50 pointer-events-none"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 20 }}
          transition={{ duration: 0.2, ease: 'easeOut' }}
        >
          <div className="w-[300px] bg-black/70 rounded-md overflow-hidden pointer-events-auto">
            <div className="px-4 py-2 flex items-center justify-center min-h-0">
              <span className="text-[12px] font-medium text-white text-center leading-tight">
                {data.label}
              </span>
            </div>
            <div className="h-[3px] bg-white/10">
              <motion.div
                className="h-full"
                style={{
                  width: `${progress}%`,
                  backgroundColor: accentColor,
                }}
                transition={{ duration: 0.016, ease: 'linear' }}
              />
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

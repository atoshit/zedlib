import { useEffect } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { useInteractProgressStore, useConfigStore } from '@/stores';

export function InteractProgressPrompt() {
  const { visible, data, progress, keyPressed, setKeyPressed } =
    useInteractProgressStore();
  const accentColor = useConfigStore((s) => s.config.accentColor);

  useEffect(() => {
    if (!keyPressed) return;
    const t = setTimeout(() => setKeyPressed(false), 150);
    return () => clearTimeout(t);
  }, [keyPressed, setKeyPressed]);

  if (!visible || !data) return null;

  const hasKey = data.key != null && data.key.length > 0;
  const leftPct = Math.max(0, Math.min(1, data.x)) * 100;
  const topPct = Math.max(0, Math.min(1, data.y)) * 100;
  const showBar = progress > 0;

  return (
    <AnimatePresence>
      <motion.div
        className="fixed z-50 pointer-events-none"
        style={{
          left: `${leftPct}%`,
          top: `${topPct}%`,
          transform: 'translate(-50%, -50%)',
        }}
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.95 }}
        transition={{ duration: 0.15 }}
      >
        <div className="flex w-fit flex-col rounded-md overflow-hidden bg-black/70 shadow-lg">
          <div className="flex w-fit items-center gap-2 py-1.5 pl-1.5 pr-2">
            {hasKey && (
              <motion.div
                className="flex items-center justify-center flex-shrink-0 w-8 h-8 rounded-md"
                style={{ backgroundColor: accentColor }}
                animate={keyPressed ? { scale: [1, 0.92, 1] } : {}}
                transition={{ duration: 0.15 }}
              >
                <span className="text-sm font-bold text-white select-none">
                  {data.key}
                </span>
              </motion.div>
            )}
            <div className="py-0.5">
              <span className="text-[13px] font-medium text-white whitespace-nowrap">
                {data.label}
              </span>
            </div>
          </div>
          {showBar && (
            <div className="h-[3px] bg-white/10">
              <motion.div
                className="h-full"
                style={{
                  width: `${Math.min(100, progress)}%`,
                  backgroundColor: accentColor,
                }}
                transition={{ duration: 0.05, ease: 'linear' }}
              />
            </div>
          )}
        </div>
      </motion.div>
    </AnimatePresence>
  );
}

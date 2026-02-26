import { motion } from 'framer-motion';
import type { MenuInfoData } from '@/types';

interface MenuInfoPanelProps {
  data: MenuInfoData[];
  color: string;
}

export function MenuInfoPanel({ data, color }: MenuInfoPanelProps) {
  if (!data.length) return null;

  return (
    <motion.div
      className="absolute top-0 left-full ml-2 w-[240px] z-50"
      initial={{ opacity: 0, x: -10 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -10 }}
      transition={{ duration: 0.15, ease: 'easeOut' }}
    >
      <div className="rounded-lg overflow-hidden bg-black/70">
        <div className="h-[3px]" style={{ backgroundColor: color }} />
        <div className="p-3 space-y-0">
          {data.map((row, i) => (
            <div
              key={i}
              className={`flex justify-between items-center py-2 ${
                i < data.length - 1 ? 'border-b border-white/[0.06]' : ''
              }`}
            >
              <span className="text-[11px] text-white/40 uppercase tracking-wide">{row.label}</span>
              <span className="text-[12px] text-white font-medium">{row.value}</span>
            </div>
          ))}
        </div>
      </div>
    </motion.div>
  );
}

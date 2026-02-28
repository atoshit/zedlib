import { motion } from 'framer-motion';

interface MenuHeaderProps {
  title: string;
  banner?: string;
  color?: string;
  itemCount: number;
  activeIndex: number;
  canGoBack: boolean;
}

export function MenuHeader({
  title,
  banner,
  color,
  itemCount,
  activeIndex,
  canGoBack,
}: MenuHeaderProps) {
  if (banner) {
    return (
      <motion.div
        className="relative overflow-hidden"
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.15 }}
      >
        {title && (
          <div className="absolute inset-0 z-10 flex items-center justify-center">
            <h2 className="text-[35px] font-bold text-white tracking-wide uppercase drop-shadow-lg">
              {title}
            </h2>
          </div>
        )}
        <img
          src={banner}
          alt=""
          className="w-full h-[100px] object-cover block"
          draggable={false}
        />
        <span className="absolute bottom-2 right-3 text-[10px] text-white/60 font-mono drop-shadow-md">
          {activeIndex + 1} / {itemCount}
        </span>
      </motion.div>
    );
  }

  return (
    <motion.div
      className="relative overflow-hidden"
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.15 }}
    >
      <div
        className="px-5 py-5"
        style={color ? { backgroundColor: color } : { backgroundColor: '#0a0a0a' }}
      >
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            {canGoBack && (
              <i className="fa-solid fa-arrow-left text-xs text-white/70" />
            )}
            <h2 className="text-[15px] font-bold text-white tracking-wide uppercase">
              {title}
            </h2>
          </div>
          <span className="text-[10px] text-white/50 font-mono">
            {activeIndex + 1} / {itemCount}
          </span>
        </div>
      </div>
    </motion.div>
  );
}

import { motion } from 'framer-motion';
import { useConfigStore } from '@/stores';

interface MenuHeaderProps {
  title: string;
  banner?: string;
  color?: string;
  itemCount: number;
  activeIndex: number;
  canGoBack: boolean;
}

const TITLE_MAX_FONT_BANNER = 30;
const TITLE_MIN_FONT_BANNER = 12;
const TITLE_MAX_FONT_NO_BANNER = 15;
const TITLE_MIN_FONT_NO_BANNER = 10;
const TITLE_WIDTH_AVAILABLE = 300;

function getTitleFontSize(length: number, maxPx: number, minPx: number): number {
  if (length <= 0) return maxPx;
  const size = TITLE_WIDTH_AVAILABLE / (length * 0.6);
  return Math.round(Math.min(maxPx, Math.max(minPx, size)));
}

export function MenuHeader({
  title,
  banner,
  color,
  itemCount,
  activeIndex,
  canGoBack,
}: MenuHeaderProps) {
  const { showTitle, showItemCount } = useConfigStore((s) => s.config);
  const titleLen = (title || '').length;
  const fontSizeBanner = getTitleFontSize(titleLen, TITLE_MAX_FONT_BANNER, TITLE_MIN_FONT_BANNER);
  const fontSizeNoBanner = getTitleFontSize(titleLen, TITLE_MAX_FONT_NO_BANNER, TITLE_MIN_FONT_NO_BANNER);

  if (banner) {
    return (
      <motion.div
        className="relative overflow-hidden"
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.15 }}
      >
        {showTitle && title && (
          <div className="absolute inset-0 z-10 flex items-center justify-center overflow-hidden px-2">
            <h2
              className="font-bold text-white tracking-wide uppercase drop-shadow-lg whitespace-nowrap"
              style={{ fontSize: fontSizeBanner }}
            >
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
        {showItemCount && (
          <span className="absolute bottom-2 right-3 text-[10px] text-white/60 font-mono drop-shadow-md">
            {activeIndex + 1} / {itemCount}
          </span>
        )}
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
        <div className="flex items-center justify-between gap-2 min-w-0">
          <div className="flex items-center gap-2.5 min-w-0 flex-1 overflow-hidden">
            {canGoBack && (
              <i className="fa-solid fa-arrow-left text-xs text-white/70 flex-shrink-0" />
            )}
            {showTitle && title && (
              <h2
                className="font-bold text-white tracking-wide uppercase whitespace-nowrap min-w-0"
                style={{ fontSize: fontSizeNoBanner }}
              >
                {title}
              </h2>
            )}
          </div>
          {showItemCount && (
            <span className="text-[10px] text-white/50 font-mono">
              {activeIndex + 1} / {itemCount}
            </span>
          )}
        </div>
      </div>
    </motion.div>
  );
}

import type { MenuSlider as MenuSliderType } from '@/types';

interface MenuItemSliderProps {
  item: MenuSliderType;
  isActive: boolean;
  index: number;
  onHover: () => void;
}

export function MenuItemSlider({ item, isActive, onHover }: MenuItemSliderProps) {
  const percentage = ((item.value - item.min) / (item.max - item.min)) * 100;

  return (
    <div
      className={`
        menu-item-shine relative px-4 py-1.5 cursor-pointer transition-colors duration-100 h-[40px]
        ${isActive ? 'active bg-white/[0.08]' : ''}
        ${item.disabled ? 'opacity-40 cursor-not-allowed' : ''}
      `}
      style={isActive ? { borderLeft: '2px solid var(--menu-color)' } : { borderLeft: '2px solid transparent' }}
      onMouseEnter={onHover}
      role="slider"
      aria-valuenow={item.value}
      aria-valuemin={item.min}
      aria-valuemax={item.max}
    >
      <div className="flex items-center justify-between mb-1">
        <span className="text-[13px] font-medium text-white">
          {item.label}
        </span>
        <span
          className="text-xs font-mono"
          style={{ color: isActive ? 'var(--menu-color)' : 'rgba(255,255,255,0.5)' }}
        >
          {item.value}
        </span>
      </div>
      <div className="w-full h-1 bg-white/10 rounded-full overflow-hidden">
        <div
          className="h-full rounded-full transition-all duration-100"
          style={{ backgroundColor: 'var(--menu-color)', width: `${percentage}%` }}
        />
      </div>
    </div>
  );
}

import type { MenuList as MenuListType } from '@/types';
import { MenuIcon } from './MenuIcon';

interface MenuItemListProps {
  item: MenuListType;
  isActive: boolean;
  index: number;
  onHover: () => void;
}

export function MenuItemList({ item, isActive, onHover }: MenuItemListProps) {
  const currentItem = item.items[item.currentIndex];

  return (
    <div
      className={`
        menu-item-shine relative px-4 py-2.5 cursor-pointer transition-colors duration-100 h-[40px] flex items-center
        ${isActive ? 'active bg-white/[0.08]' : ''}
        ${item.disabled ? 'opacity-40 cursor-not-allowed' : ''}
      `}
      style={isActive ? { borderLeft: '2px solid var(--menu-color)' } : { borderLeft: '2px solid transparent' }}
      onMouseEnter={onHover}
      role="menuitem"
    >
      <div className="flex items-center justify-between w-full">
        <div className="flex items-center gap-2.5">
          {item.icon && (
            <MenuIcon
              icon={item.icon}
              className="text-sm w-4 text-center"
              style={{ color: isActive ? 'var(--menu-color)' : 'rgba(255,255,255,0.5)' }}
            />
          )}
          <span className="text-[13px] font-medium text-white">
            {item.label}
          </span>
        </div>
        <div className="flex items-center gap-2">
          <i
            className="fa-solid fa-chevron-left text-[9px]"
            style={{ color: isActive ? 'var(--menu-color)' : 'rgba(255,255,255,0.3)' }}
          />
          <span
            className="text-xs min-w-[60px] text-center"
            style={{ color: isActive ? 'var(--menu-color)' : 'rgba(255,255,255,0.7)' }}
          >
            {currentItem?.label ?? '—'}
          </span>
          <i
            className="fa-solid fa-chevron-right text-[9px]"
            style={{ color: isActive ? 'var(--menu-color)' : 'rgba(255,255,255,0.3)' }}
          />
        </div>
      </div>
    </div>
  );
}

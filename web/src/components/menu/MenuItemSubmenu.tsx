import type { MenuSubmenu as MenuSubmenuType } from '@/types';
import { MenuIcon } from './MenuIcon';

interface MenuItemSubmenuProps {
  item: MenuSubmenuType;
  isActive: boolean;
  index: number;
  onSelect: () => void;
  onHover: () => void;
}

export function MenuItemSubmenu({ item, isActive, onSelect, onHover }: MenuItemSubmenuProps) {
  return (
    <div
      className={`
        menu-item-shine relative px-4 py-2.5 cursor-pointer transition-colors duration-100 h-[40px] flex items-center
        ${isActive ? 'active bg-white/[0.08]' : ''}
        ${item.disabled ? 'opacity-40 cursor-not-allowed' : ''}
      `}
      style={isActive ? { borderLeft: '2px solid var(--menu-color)' } : { borderLeft: '2px solid transparent' }}
      onClick={() => !item.disabled && onSelect()}
      onMouseEnter={onHover}
      role="menuitem"
      aria-haspopup="true"
      aria-disabled={item.disabled}
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
        <i
          className="fa-solid fa-chevron-right text-[10px]"
          style={{ color: isActive ? 'var(--menu-color)' : 'rgba(255,255,255,0.3)' }}
        />
      </div>
    </div>
  );
}

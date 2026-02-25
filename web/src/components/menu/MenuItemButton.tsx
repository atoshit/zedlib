import type { MenuButton as MenuButtonType } from '@/types';
import { MenuIcon } from './MenuIcon';

interface MenuItemButtonProps {
  item: MenuButtonType;
  isActive: boolean;
  index: number;
  onSelect: () => void;
  onHover: () => void;
}

export function MenuItemButton({ item, isActive, onSelect, onHover }: MenuItemButtonProps) {
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
      aria-disabled={item.disabled}
    >
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
    </div>
  );
}

import type { MenuInfoButton as MenuInfoButtonType } from '@/types';
import { MenuIcon } from './MenuIcon';

interface MenuItemInfoProps {
  item: MenuInfoButtonType;
  isActive: boolean;
  onHover: () => void;
}

export function MenuItemInfo({ item, isActive, onHover }: MenuItemInfoProps) {
  return (
    <div
      className={`
        menu-item-shine relative px-4 py-2.5 cursor-default transition-colors duration-100 h-[40px] flex items-center
        ${isActive ? 'active bg-white/[0.08]' : ''}
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
        <i
          className="fa-solid fa-circle-info text-xs"
          style={{ color: isActive ? 'var(--menu-color)' : 'rgba(255,255,255,0.25)' }}
        />
      </div>
    </div>
  );
}

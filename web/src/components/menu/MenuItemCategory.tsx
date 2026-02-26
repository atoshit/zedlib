import type { MenuCategory as MenuCategoryType } from '@/types';
import { MenuIcon } from './MenuIcon';

interface MenuItemCategoryProps {
  item: MenuCategoryType;
  isActive: boolean;
  isExpanded: boolean;
  onSelect: () => void;
  onHover: () => void;
}

export function MenuItemCategory({
  item,
  isActive,
  isExpanded,
  onSelect,
  onHover,
}: MenuItemCategoryProps) {
  return (
    <div
      className={`
        menu-item-shine relative px-4 py-2.5 cursor-pointer transition-colors duration-100 h-[40px] flex items-center
        ${isActive ? 'active bg-white/[0.08]' : ''}
        ${item.disabled ? 'opacity-40 cursor-not-allowed' : ''}
      `}
      style={
        isActive
          ? { borderLeft: '2px solid var(--menu-color)' }
          : { borderLeft: '2px solid transparent' }
      }
      onClick={() => !item.disabled && onSelect()}
      onMouseEnter={onHover}
      role="menuitem"
      aria-expanded={isExpanded}
      aria-disabled={item.disabled}
    >
      <div className="flex items-center gap-2 w-full">
        <i
          className={`fa-solid fa-chevron-right text-[10px] flex-shrink-0 transition-transform duration-150 ${
            isExpanded ? 'rotate-90' : ''
          }`}
          style={{ color: isActive ? 'var(--menu-color)' : 'rgba(255,255,255,0.4)' }}
        />
        <span className="flex-1 min-w-0 h-px bg-white/10 mx-1" aria-hidden />
        <span className="text-[12px] font-medium text-white/90 uppercase tracking-wide whitespace-nowrap flex-shrink-0">
          {item.icon && (
            <MenuIcon
              icon={item.icon}
              className="inline-block mr-1.5 text-xs"
              style={{ color: isActive ? 'var(--menu-color)' : 'rgba(255,255,255,0.5)' }}
            />
          )}
          {item.label}
        </span>
        <span className="flex-1 min-w-0 h-px bg-white/10 ml-1" aria-hidden />
      </div>
    </div>
  );
}

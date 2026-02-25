import type { MenuSearchItem } from '@/types';
import { MenuIcon } from './MenuIcon';

interface MenuItemSearchProps {
  item: MenuSearchItem;
  isActive: boolean;
  searchActive: boolean;
  searchQuery: string;
  onSelect: () => void;
  onHover: () => void;
}

export function MenuItemSearch({
  item,
  isActive,
  searchActive,
  searchQuery,
  onSelect,
  onHover,
}: MenuItemSearchProps) {
  const placeholder = item.placeholder || 'Rechercher...';

  return (
    <div
      className={`
        menu-item-shine relative px-4 py-2.5 cursor-pointer transition-colors duration-100 h-[40px] flex items-center
        ${isActive ? 'active bg-white/[0.08]' : ''}
      `}
      style={isActive ? { borderLeft: '2px solid var(--menu-color)' } : { borderLeft: '2px solid transparent' }}
      onClick={onSelect}
      onMouseEnter={onHover}
      role="menuitem"
    >
      <div className="flex items-center gap-2.5 w-full">
        <MenuIcon
          icon={item.icon || 'magnifying-glass'}
          className="text-sm w-4 text-center flex-shrink-0"
          style={{ color: isActive || searchActive ? 'var(--menu-color)' : 'rgba(255,255,255,0.5)' }}
        />
        <div className="flex-1 min-w-0 flex items-center">
          {searchActive ? (
            <span className="text-[13px] font-medium text-white flex items-center">
              {searchQuery || (
                <span className="text-white/30">{placeholder}</span>
              )}
              <span
                className="inline-block w-[2px] h-[14px] ml-[1px] flex-shrink-0"
                style={{
                  backgroundColor: 'var(--menu-color)',
                  animation: 'blink 1s step-end infinite',
                }}
              />
            </span>
          ) : (
            <span className="text-[13px] font-medium text-white/50">
              {item.label}
            </span>
          )}
        </div>
        {searchActive && searchQuery && (
          <span className="text-[10px] text-white/30 flex-shrink-0 ml-2">
            ENTRÉE = reset
          </span>
        )}
      </div>
    </div>
  );
}

import type { MenuCheckbox as MenuCheckboxType } from '@/types';
import { MenuIcon } from './MenuIcon';

interface MenuItemCheckboxProps {
  item: MenuCheckboxType;
  isActive: boolean;
  index: number;
  onSelect: () => void;
  onHover: () => void;
}

export function MenuItemCheckbox({ item, isActive, onSelect, onHover }: MenuItemCheckboxProps) {
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
      role="menuitemcheckbox"
      aria-checked={item.checked}
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
        <div
          className="w-4 h-4 rounded border flex items-center justify-center transition-all duration-150"
          style={
            item.checked
              ? { backgroundColor: 'var(--menu-color)', borderColor: 'var(--menu-color)' }
              : { borderColor: 'rgba(255,255,255,0.3)', backgroundColor: 'transparent' }
          }
        >
          {item.checked && (
            <i className="fa-solid fa-check text-[8px] text-white" />
          )}
        </div>
      </div>
    </div>
  );
}

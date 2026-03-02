import { MenuIcon } from '../menu/MenuIcon';
import { useConfigStore } from '@/stores';
import type { ContextOption } from '@/types/context';

interface ContextMenuItemProps {
  option: ContextOption;
  isActive: boolean;
  onHover: () => void;
  onSelect: () => void;
}

export function ContextMenuItem({ option, isActive, onHover, onSelect }: ContextMenuItemProps) {
  const accentColor = useConfigStore((s) => s.config.accentColor);
  const hasChildren = option.children && option.children.length > 0;

  return (
    <div
      className={`
        menu-item-shine relative px-3 cursor-pointer transition-colors duration-100 flex items-center gap-2.5 h-[32px]
        ${isActive ? 'active bg-white/[0.08]' : ''}
        ${option.disabled ? 'opacity-40 cursor-not-allowed' : ''}
      `}
      style={isActive ? { borderLeft: `2px solid ${accentColor}` } : { borderLeft: '2px solid transparent' }}
      onClick={() => {
        if (option.disabled || hasChildren) return;
        onSelect();
      }}
      onMouseEnter={onHover}
      role="menuitem"
      aria-disabled={option.disabled}
    >
      {option.icon && (
        <MenuIcon
          icon={option.icon}
          className="text-sm w-4 text-center flex-shrink-0"
          style={{ color: isActive ? accentColor : 'rgba(255,255,255,0.5)' }}
        />
      )}
      <span className="text-[13px] font-medium text-white truncate flex-1">
        {option.label}
      </span>
      {hasChildren && (
        <i className="fa-solid fa-chevron-right text-[10px] text-white/40 flex-shrink-0" />
      )}
    </div>
  );
}

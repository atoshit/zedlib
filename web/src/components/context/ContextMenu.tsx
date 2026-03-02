import { useEffect, useState, useCallback, useMemo } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { useContextStore } from '@/stores/contextStore';
import { ContextMenuItem } from './ContextMenuItem';
import type { ContextOption } from '@/types/context';

const MENU_WIDTH = 220;
const ITEM_HEIGHT = 32;
const PADDING_Y = 4;
const SCREEN_PADDING = 12;
const SUBMENU_GAP = 2;

interface SubmenuData {
  parentId: string;
  options: ContextOption[];
  itemY: number;
  parentX: number;
}

function clampMenuPos(x: number, y: number, itemCount: number) {
  const vw = window.innerWidth;
  const vh = window.innerHeight;
  const h = itemCount * ITEM_HEIGHT + PADDING_Y * 2;
  let cx = x;
  let cy = y;
  if (cx + MENU_WIDTH + SCREEN_PADDING > vw) cx = vw - MENU_WIDTH - SCREEN_PADDING;
  if (cx < SCREEN_PADDING) cx = SCREEN_PADDING;
  if (cy + h + SCREEN_PADDING > vh) cy = vh - h - SCREEN_PADDING;
  if (cy < SCREEN_PADDING) cy = SCREEN_PADDING;
  return { x: cx, y: cy };
}

interface PanelProps {
  options: ContextOption[];
  position: { x: number; y: number };
  level: number;
  activeSubmenuId?: string;
  onSubmenuOpen: (level: number, option: ContextOption, itemY: number, panelX: number) => void;
  onSubmenuClose: (level: number) => void;
  onSelect: (option: ContextOption) => void;
}

function ContextPanel({
  options,
  position,
  level,
  activeSubmenuId,
  onSubmenuOpen,
  onSubmenuClose,
  onSelect,
}: PanelProps) {
  const [hoveredIndex, setHoveredIndex] = useState(-1);

  const clamped = useMemo(
    () => clampMenuPos(position.x, position.y, options.length),
    [position.x, position.y, options.length],
  );

  const handleItemHover = useCallback(
    (option: ContextOption, index: number) => {
      setHoveredIndex(index);
      if (option.children && option.children.length > 0) {
        const itemY = clamped.y + PADDING_Y + index * ITEM_HEIGHT;
        onSubmenuOpen(level, option, itemY, clamped.x);
      } else {
        onSubmenuClose(level);
      }
    },
    [level, clamped.x, clamped.y, onSubmenuOpen, onSubmenuClose],
  );

  return (
    <motion.div
      className="context-menu-panel fixed rounded-md overflow-hidden shadow-2xl shadow-black/60"
      style={{
        left: clamped.x,
        top: clamped.y,
        width: MENU_WIDTH,
        zIndex: 100 + level,
      }}
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ duration: 0.1, ease: 'easeOut' }}
    >
      <div className="bg-black/70 rounded-md overflow-hidden">
        <div style={{ padding: `${PADDING_Y}px 0` }}>
          {options.map((option, index) => (
            <ContextMenuItem
              key={option.id}
              option={option}
              isActive={hoveredIndex === index || activeSubmenuId === option.id}
              onHover={() => handleItemHover(option, index)}
              onSelect={() => onSelect(option)}
            />
          ))}
        </div>
      </div>
    </motion.div>
  );
}

export function ContextMenu() {
  const { visible, options, position, closeMenu, selectOption } = useContextStore();
  const [submenus, setSubmenus] = useState<SubmenuData[]>([]);

  useEffect(() => {
    if (!visible) setSubmenus([]);
  }, [visible]);

  const handleSubmenuOpen = useCallback(
    (level: number, option: ContextOption, itemY: number, panelX: number) => {
      if (!option.children || option.children.length === 0) return;
      setSubmenus((prev) => [
        ...prev.slice(0, level),
        { parentId: option.id, options: option.children!, itemY, parentX: panelX },
      ]);
    },
    [],
  );

  const handleSubmenuClose = useCallback((level: number) => {
    setSubmenus((prev) => prev.slice(0, level));
  }, []);

  useEffect(() => {
    if (!visible) return;
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        closeMenu();
      }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [visible, closeMenu]);

  if (!visible) return null;

  return (
    <>
      <div
        className="fixed inset-0 z-[90]"
        onClick={() => closeMenu()}
        onContextMenu={(e) => e.preventDefault()}
      />

      <AnimatePresence>
        <ContextPanel
          key="root"
          options={options}
          position={position}
          level={0}
          activeSubmenuId={submenus[0]?.parentId}
          onSubmenuOpen={handleSubmenuOpen}
          onSubmenuClose={handleSubmenuClose}
          onSelect={selectOption}
        />

        {submenus.map((sub, index) => {
          let x = sub.parentX + MENU_WIDTH + SUBMENU_GAP;
          if (x + MENU_WIDTH + SCREEN_PADDING > window.innerWidth) {
            x = sub.parentX - MENU_WIDTH - SUBMENU_GAP;
          }

          return (
            <ContextPanel
              key={sub.parentId}
              options={sub.options}
              position={{ x, y: sub.itemY }}
              level={index + 1}
              activeSubmenuId={submenus[index + 1]?.parentId}
              onSubmenuOpen={handleSubmenuOpen}
              onSubmenuClose={handleSubmenuClose}
              onSelect={selectOption}
            />
          );
        })}
      </AnimatePresence>
    </>
  );
}

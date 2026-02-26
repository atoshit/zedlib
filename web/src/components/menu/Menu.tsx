import { useRef, useEffect, useMemo, useCallback } from 'react';
import { useVirtualizer } from '@tanstack/react-virtual';
import { AnimatePresence, motion } from 'framer-motion';
import { useMenuStore } from '@/stores';
import { useMenuNavigation } from '@/hooks';
import { isFiveM } from '@/nui';
import { MenuHeader } from './MenuHeader';
import { MenuItemButton } from './MenuItemButton';
import { MenuItemCheckbox } from './MenuItemCheckbox';
import { MenuItemSubmenu } from './MenuItemSubmenu';
import { MenuItemList } from './MenuItemList';
import { MenuItemSlider } from './MenuItemSlider';
import { MenuItemSearch } from './MenuItemSearch';
import { MenuItemInfo } from './MenuItemInfo';
import { MenuInfoPanel } from './MenuInfoPanel';
import { MenuSeparatorItem } from './MenuSeparator';
import type { MenuItem, MenuInfoButton } from '@/types';

const DEFAULT_COLOR = '#e74c3c';
const ITEM_HEIGHT = 40;
const SEPARATOR_HEIGHT = 9;
const MAX_HEIGHT = 400;

function getItemHeight(item: MenuItem) {
  return item.type === 'separator' ? SEPARATOR_HEIGHT : ITEM_HEIGHT;
}

export function Menu() {
  const { visible, navigation, menus, searchState, setActiveIndex, selectCurrent } =
    useMenuStore();
  const scrollRef = useRef<HTMLDivElement>(null);

  const currentMenuId = navigation.stack[navigation.stack.length - 1];
  const currentMenu = currentMenuId ? menus[currentMenuId] : undefined;
  const activeIndex = currentMenuId ? (navigation.activeIndex[currentMenuId] ?? 0) : 0;
  const canGoBack = navigation.stack.length > 1;

  const rootMenuId = navigation.stack[0];
  const rootMenu = rootMenuId ? menus[rootMenuId] : undefined;
  const menuColor = currentMenu?.color || rootMenu?.color || DEFAULT_COLOR;
  const menuBanner = currentMenu?.banner || rootMenu?.banner;

  const searchInfo = currentMenuId ? searchState[currentMenuId] : undefined;
  const isSearchActive = searchInfo?.active ?? false;
  const searchQuery = searchInfo?.query ?? '';

  useMenuNavigation(!isFiveM && !isSearchActive);

  const allItems = currentMenu?.items ?? [];

  const displayItems = useMemo(() => {
    if (!isSearchActive || !searchQuery.trim()) return allItems;
    const q = searchQuery.toLowerCase();
    return allItems.filter((item) => {
      if (item.type === 'search') return true;
      if (item.type === 'separator') return false;
      return 'label' in item && item.label.toLowerCase().includes(q);
    });
  }, [allItems, isSearchActive, searchQuery]);

  const selectableMap = useMemo(() => {
    const map: number[] = [];
    let si = 0;
    for (let i = 0; i < displayItems.length; i++) {
      if (displayItems[i].type === 'separator') {
        map.push(-1);
      } else {
        map.push(si);
        si++;
      }
    }
    return map;
  }, [displayItems]);

  const selectableCount = useMemo(
    () => displayItems.filter((i) => i.type !== 'separator').length,
    [displayItems],
  );

  const virtualizer = useVirtualizer({
    count: displayItems.length,
    getScrollElement: () => scrollRef.current,
    estimateSize: (i) => getItemHeight(displayItems[i]),
    overscan: 8,
  });

  const scrollToRawIndex = useCallback(
    (targetRaw: number, behavior: ScrollBehavior = 'auto') => {
      const el = scrollRef.current;
      if (!el || el.clientHeight === 0 || targetRaw < 0) return;

      let offset = 0;
      for (let i = 0; i < targetRaw; i++) {
        offset += getItemHeight(displayItems[i]);
      }
      const itemH = getItemHeight(displayItems[targetRaw]);

      const viewTop = el.scrollTop;
      const viewBottom = viewTop + el.clientHeight;

      if (offset < viewTop) {
        el.scrollTo({ top: offset, behavior });
      } else if (offset + itemH > viewBottom) {
        el.scrollTo({ top: offset + itemH - el.clientHeight, behavior });
      }
    },
    [displayItems],
  );

  const findRawIndex = useCallback(
    (selIdx: number) => {
      for (let i = 0; i < displayItems.length; i++) {
        if (selectableMap[i] === selIdx) return i;
      }
      return -1;
    },
    [displayItems, selectableMap],
  );

  useEffect(() => {
    if (!isSearchActive || !currentMenuId) return;

    const handler = (e: KeyboardEvent) => {
      const store = useMenuStore.getState();

      if (e.key === 'Escape') {
        e.preventDefault();
        store.toggleSearch(currentMenuId);
        return;
      }
      if (e.key === 'ArrowUp') {
        e.preventDefault();
        store.moveUp();
        return;
      }
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        store.moveDown();
        return;
      }
      if (e.key === 'ArrowLeft' || e.key === 'ArrowRight') {
        e.preventDefault();
        return;
      }
      if (e.key === 'Enter') {
        e.preventDefault();
        store.selectCurrent();
        return;
      }
      if (e.key === 'Backspace') {
        e.preventDefault();
        const q = store.searchState[currentMenuId]?.query ?? '';
        if (q.length === 0) {
          store.toggleSearch(currentMenuId);
        } else {
          store.setSearchQuery(currentMenuId, q.slice(0, -1));
        }
        return;
      }
      if (e.key.length === 1 && !e.ctrlKey && !e.altKey && !e.metaKey) {
        e.preventDefault();
        const q = store.searchState[currentMenuId]?.query ?? '';
        store.setSearchQuery(currentMenuId, q + e.key);
      }
    };

    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [isSearchActive, currentMenuId]);

  const lastScrollTime = useRef(0);

  useEffect(() => {
    const raw = findRawIndex(activeIndex);
    if (raw < 0) return;
    const now = Date.now();
    const fast = now - lastScrollTime.current < 150;
    lastScrollTime.current = now;
    scrollToRawIndex(raw, fast ? 'auto' : 'smooth');
  }, [activeIndex, findRawIndex, scrollToRawIndex]);

  useEffect(() => {
    const raw = findRawIndex(activeIndex);
    if (raw < 0) return;
    const timer = setTimeout(() => scrollToRawIndex(raw, 'auto'), 220);
    return () => clearTimeout(timer);
  }, [currentMenuId]);

  const renderItem = useCallback(
    (item: MenuItem, _rawIndex: number, selectableIdx: number) => {
      if (item.type === 'separator') {
        return <MenuSeparatorItem />;
      }

      const isActive = selectableIdx === activeIndex;

      const commonProps = {
        isActive,
        index: 0,
        onHover: () => setActiveIndex(currentMenuId!, selectableIdx),
        onSelect: () => {
          setActiveIndex(currentMenuId!, selectableIdx);
          selectCurrent();
        },
      };

      switch (item.type) {
        case 'button':
          return <MenuItemButton item={item} {...commonProps} />;
        case 'checkbox':
          return <MenuItemCheckbox item={item} {...commonProps} />;
        case 'submenu':
          return <MenuItemSubmenu item={item} {...commonProps} />;
        case 'list':
          return (
            <MenuItemList
              item={item}
              isActive={isActive}
              index={0}
              onHover={() => setActiveIndex(currentMenuId!, selectableIdx)}
            />
          );
        case 'slider':
          return (
            <MenuItemSlider
              item={item}
              isActive={isActive}
              index={0}
              onHover={() => setActiveIndex(currentMenuId!, selectableIdx)}
            />
          );
        case 'search':
          return (
            <MenuItemSearch
              item={item}
              searchActive={isSearchActive}
              searchQuery={searchQuery}
              {...commonProps}
            />
          );
        case 'info':
          return (
            <MenuItemInfo
              item={item}
              isActive={isActive}
              onHover={() => setActiveIndex(currentMenuId!, selectableIdx)}
            />
          );
        default:
          return null;
      }
    },
    [activeIndex, currentMenuId, setActiveIndex, selectCurrent, isSearchActive, searchQuery],
  );

  const activeInfoItem = useMemo<MenuInfoButton | null>(() => {
    const selectableItems = displayItems.filter((i) => i.type !== 'separator');
    const item = selectableItems[activeIndex];
    return item?.type === 'info' ? item : null;
  }, [displayItems, activeIndex]);

  if (!visible || !currentMenu) return null;

  const totalHeight = displayItems.reduce(
    (h, item) => h + (item.type === 'separator' ? SEPARATOR_HEIGHT : ITEM_HEIGHT),
    0,
  );
  const containerHeight = Math.min(totalHeight + 8, MAX_HEIGHT);

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={currentMenuId}
        className="fixed top-[4%] left-[3%] w-[340px] z-50"
        style={{ '--menu-color': menuColor } as React.CSSProperties}
        initial={{ opacity: 0, x: -20, scale: 0.97 }}
        animate={{ opacity: 1, x: 0, scale: 1 }}
        exit={{ opacity: 0, x: -20, scale: 0.97 }}
        transition={{ duration: 0.18, ease: [0.25, 0.46, 0.45, 0.94] }}
      >
        <div className="relative rounded-lg overflow-hidden shadow-2xl shadow-black/60">
          <MenuHeader
            title={currentMenu.title}
            banner={menuBanner}
            color={menuColor !== DEFAULT_COLOR ? menuColor : undefined}
            itemCount={selectableCount}
            activeIndex={activeIndex}
            canGoBack={canGoBack}
          />

          <div
            ref={scrollRef}
            className="overflow-y-auto bg-black/70"
            style={{ height: containerHeight, scrollbarWidth: 'none' }}
            role="menu"
          >
            <div
              style={{
                height: virtualizer.getTotalSize(),
                width: '100%',
                position: 'relative',
              }}
            >
              {virtualizer.getVirtualItems().map((vItem) => {
                const item = displayItems[vItem.index];
                const si = selectableMap[vItem.index];
                return (
                  <div
                    key={item.id}
                    style={{
                      position: 'absolute',
                      top: 0,
                      left: 0,
                      width: '100%',
                      height: vItem.size,
                      transform: `translateY(${vItem.start}px)`,
                    }}
                  >
                    {renderItem(item, vItem.index, si)}
                  </div>
                );
              })}
            </div>
          </div>
        </div>
        <AnimatePresence>
          {activeInfoItem && (
            <MenuInfoPanel data={activeInfoItem.infoData} color={menuColor} />
          )}
        </AnimatePresence>
      </motion.div>
    </AnimatePresence>
  );
}

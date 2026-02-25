import { useCallback } from 'react';
import { useMenuStore } from '@/stores';
import { useKeyboard } from './useKeyboard';

export function useMenuNavigation(enabled = true) {
  const { visible, moveUp, moveDown, selectCurrent, goBack, closeMenu } = useMenuStore();

  const handleLeft = useCallback(() => {
    const menu = useMenuStore.getState().getCurrentMenu();
    if (!menu) return;
    const idx = useMenuStore.getState().getCurrentIndex();
    const selectableItems = menu.items.filter((i) => i.type !== 'separator');
    const item = selectableItems[idx];
    if (item?.type === 'list') {
      const prevIndex =
        item.currentIndex <= 0 ? item.items.length - 1 : item.currentIndex - 1;
      useMenuStore.getState().updateItem(menu.id, item.id, { currentIndex: prevIndex });
    } else if (item?.type === 'slider') {
      const newVal = Math.max(item.min, item.value - item.step);
      useMenuStore.getState().updateItem(menu.id, item.id, { value: newVal });
    }
  }, []);

  const handleRight = useCallback(() => {
    const menu = useMenuStore.getState().getCurrentMenu();
    if (!menu) return;
    const idx = useMenuStore.getState().getCurrentIndex();
    const selectableItems = menu.items.filter((i) => i.type !== 'separator');
    const item = selectableItems[idx];
    if (item?.type === 'list') {
      const nextIndex = (item.currentIndex + 1) % item.items.length;
      useMenuStore.getState().updateItem(menu.id, item.id, { currentIndex: nextIndex });
    } else if (item?.type === 'slider') {
      const newVal = Math.min(item.max, item.value + item.step);
      useMenuStore.getState().updateItem(menu.id, item.id, { value: newVal });
    }
  }, []);

  useKeyboard(
    {
      ArrowUp: moveUp,
      ArrowDown: moveDown,
      Enter: selectCurrent,
      Backspace: goBack,
      Escape: closeMenu,
      ArrowLeft: handleLeft,
      ArrowRight: handleRight,
    },
    visible && enabled,
  );

  return { visible };
}

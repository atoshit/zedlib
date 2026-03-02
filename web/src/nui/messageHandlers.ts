import { useMenuStore } from '@/stores/menuStore';
import { useNotificationStore } from '@/stores/notificationStore';
import { useDialogStore } from '@/stores/dialogStore';
import { useConfigStore } from '@/stores/configStore';
import { useContextStore } from '@/stores/contextStore';
import { useProgressBarStore } from '@/stores/progressBarStore';
import { useInteractStore } from '@/stores/interactStore';
import { useInteractProgressStore } from '@/stores/interactProgressStore';
import { registerNuiHandler } from './handlers';
import { nuiCallback } from './bridge';
import type { MenuDefinition, MenuItem, NotificationData, DialogData } from '@/types';
import type { ContextMenuData } from '@/types/context';

export function registerAllHandlers(): void {
  registerNuiHandler('zedlib:registerMenu', (data) => {
    const menu = data as MenuDefinition;
    useMenuStore.getState().registerMenu(menu);
  });

  registerNuiHandler('zedlib:removeMenu', (data) => {
    const { id } = data as { id: string };
    useMenuStore.getState().removeMenu(id);
  });

  registerNuiHandler('zedlib:addMenuItem', (data) => {
    const { menuId, item } = data as { menuId: string; item: MenuItem };
    useMenuStore.getState().addItem(menuId, item);
  });

  registerNuiHandler('zedlib:removeMenuItem', (data) => {
    const { menuId, itemId } = data as { menuId: string; itemId: string };
    useMenuStore.getState().removeItem(menuId, itemId);
  });

  registerNuiHandler('zedlib:openMenu', (data) => {
    const { id } = data as { id: string };
    useMenuStore.getState().openMenu(id);
  });

  registerNuiHandler('zedlib:closeMenu', () => {
    useMenuStore.getState().closeMenu();
  });

  registerNuiHandler('zedlib:menuMoveUp', () => {
    useMenuStore.getState().moveUp();
  });

  registerNuiHandler('zedlib:menuMoveDown', () => {
    useMenuStore.getState().moveDown();
  });

  registerNuiHandler('zedlib:menuSelect', () => {
    useMenuStore.getState().selectCurrent();
  });

  registerNuiHandler('zedlib:menuGoBack', () => {
    useMenuStore.getState().goBack();
  });

  registerNuiHandler('zedlib:menuLeft', () => {
    const store = useMenuStore.getState();
    const menu = store.getCurrentMenu();
    if (!menu) return;
    if (store.isSearchActive()) return;
    const idx = store.getCurrentIndex();
    const selectableItems = menu.items.filter((i) => i.type !== 'separator');
    const item = selectableItems[idx];
    if (item?.type === 'list') {
      const prevIndex = item.currentIndex <= 0 ? item.items.length - 1 : item.currentIndex - 1;
      store.updateItem(menu.id, item.id, { currentIndex: prevIndex });
      if (item.onChange) {
        nuiCallback('zedlib:menuAction', {
          action: item.onChange,
          menuId: menu.id,
          itemId: item.id,
          value: item.items[prevIndex],
          index: prevIndex,
        });
      }
    } else if (item?.type === 'slider') {
      const newVal = Math.max(item.min, item.value - item.step);
      store.updateItem(menu.id, item.id, { value: newVal });
      if (item.onChange) {
        nuiCallback('zedlib:menuAction', {
          action: item.onChange,
          menuId: menu.id,
          itemId: item.id,
          value: newVal,
        });
      }
    }
  });

  registerNuiHandler('zedlib:menuRight', () => {
    const store = useMenuStore.getState();
    const menu = store.getCurrentMenu();
    if (!menu) return;
    if (store.isSearchActive()) return;
    const idx = store.getCurrentIndex();
    const selectableItems = menu.items.filter((i) => i.type !== 'separator');
    const item = selectableItems[idx];
    if (item?.type === 'list') {
      const nextIndex = (item.currentIndex + 1) % item.items.length;
      store.updateItem(menu.id, item.id, { currentIndex: nextIndex });
      if (item.onChange) {
        nuiCallback('zedlib:menuAction', {
          action: item.onChange,
          menuId: menu.id,
          itemId: item.id,
          value: item.items[nextIndex],
          index: nextIndex,
        });
      }
    } else if (item?.type === 'slider') {
      const newVal = Math.min(item.max, item.value + item.step);
      store.updateItem(menu.id, item.id, { value: newVal });
      if (item.onChange) {
        nuiCallback('zedlib:menuAction', {
          action: item.onChange,
          menuId: menu.id,
          itemId: item.id,
          value: newVal,
        });
      }
    }
  });

  registerNuiHandler('zedlib:notify', (data) => {
    const notif = data as Omit<NotificationData, 'id'>;
    useNotificationStore.getState().addNotification(notif);
  });

  registerNuiHandler('zedlib:clearNotifications', () => {
    useNotificationStore.getState().clearAll();
  });

  registerNuiHandler('zedlib:openDialog', (data) => {
    const dialog = data as DialogData;
    useDialogStore.getState().openDialog(dialog);
  });

  registerNuiHandler('zedlib:closeDialog', () => {
    useDialogStore.getState().closeDialog();
  });

  registerNuiHandler('zedlib:setConfig', (data) => {
    useConfigStore.getState().setConfig(data as Record<string, unknown>);
  });

  registerNuiHandler('zedlib:setLibConfig', (data) => {
    useConfigStore.getState().setConfig(data as Record<string, unknown>);
  });

  registerNuiHandler('zedlib:copyToClipboard', (data) => {
    const { text } = data as { text: string };
    if (text) {
      navigator.clipboard.writeText(text).catch(() => {
        const el = document.createElement('textarea');
        el.value = text;
        el.style.position = 'fixed';
        el.style.opacity = '0';
        document.body.appendChild(el);
        el.select();
        document.execCommand('copy');
        document.body.removeChild(el);
      });
    }
  });

  registerNuiHandler('zedlib:openContext', (data) => {
    const ctx = data as ContextMenuData;
    useContextStore.getState().openMenu(ctx);
  });

  registerNuiHandler('zedlib:closeContext', () => {
    useContextStore.getState().closeMenu(true);
  });

  registerNuiHandler('zedlib:startProgress', (data) => {
    const { label, duration, canCancel } = data as { label: string; duration: number; canCancel: boolean };
    useProgressBarStore.getState().show({ label, duration, canCancel });
  });

  registerNuiHandler('zedlib:stopProgress', () => {
    useProgressBarStore.getState().hide();
  });

  registerNuiHandler('zedlib:interactShow', (data) => {
    const { x, y, label, key } = data as { x: number; y: number; label: string; key?: string };
    useInteractStore.getState().show({ x, y, label, key });
  });

  registerNuiHandler('zedlib:interactHide', () => {
    useInteractStore.getState().hide();
  });

  registerNuiHandler('zedlib:interactUpdatePos', (data) => {
    const { x, y } = data as { x: number; y: number };
    useInteractStore.getState().updatePosition(x, y);
  });

  registerNuiHandler('zedlib:interactKeyPressed', () => {
    useInteractStore.getState().setKeyPressed(true);
  });

  registerNuiHandler('zedlib:interactProgressShow', (data) => {
    const { x, y, label, key, duration } = data as {
      x: number;
      y: number;
      label: string;
      key?: string;
      duration: number;
    };
    useInteractProgressStore.getState().show({ x, y, label, key, duration });
  });

  registerNuiHandler('zedlib:interactProgressHide', () => {
    useInteractProgressStore.getState().hide();
  });

  registerNuiHandler('zedlib:interactProgressUpdatePos', (data) => {
    const { x, y } = data as { x: number; y: number };
    useInteractProgressStore.getState().updatePosition(x, y);
  });

  registerNuiHandler('zedlib:interactProgressUpdateProgress', (data) => {
    const { progress } = data as { progress: number };
    useInteractProgressStore.getState().setProgress(progress);
  });

  registerNuiHandler('zedlib:interactProgressKeyPressed', () => {
    useInteractProgressStore.getState().setKeyPressed(true);
  });
}

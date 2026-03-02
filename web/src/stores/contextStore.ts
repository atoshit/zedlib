import { create } from 'zustand';
import { nuiCallback } from '@/nui/bridge';
import type { ContextOption, ContextMenuData } from '@/types/context';

interface ContextStore {
  visible: boolean;
  options: ContextOption[];
  entityType: string;
  entityId: number;
  position: { x: number; y: number };

  openMenu: (data: ContextMenuData) => void;
  closeMenu: (silent?: boolean) => void;
  selectOption: (option: ContextOption) => void;
}

export const useContextStore = create<ContextStore>((set, get) => ({
  visible: false,
  options: [],
  entityType: '',
  entityId: 0,
  position: { x: 0, y: 0 },

  openMenu: (data: ContextMenuData) =>
    set({
      visible: true,
      options: data.options,
      entityType: data.entityType,
      entityId: data.entityId,
      position: data.position,
    }),

  closeMenu: (silent?: boolean) => {
    const state = get();
    if (!state.visible) return;
    set({ visible: false });
    if (!silent) nuiCallback('zedlib:contextClosed');
  },

  selectOption: (option: ContextOption) => {
    if (option.disabled) return;
    if (option.children && option.children.length > 0) return;
    if (option.onSelect) {
      const state = get();
      nuiCallback('zedlib:contextAction', {
        action: option.onSelect,
        entityId: state.entityId,
        entityType: state.entityType,
      });
    }
    get().closeMenu();
  },
}));

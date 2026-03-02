import { create } from 'zustand';
import type { MenuDefinition, MenuItem, MenuNavigationState } from '@/types';
import { registry, Sound } from '@/core';
import { nuiCallback } from '@/nui';

interface SearchInfo {
  active: boolean;
  query: string;
}

function filterByCategory(items: MenuItem[], expandedCategoryId: string | null): MenuItem[] {
  return items.filter((item) => {
    if (item.type === 'category') return true;
    const cat = 'category' in item ? (item as { category?: string }).category : undefined;
    if (cat == null) return true;
    return cat === expandedCategoryId;
  });
}

interface MenuStore {
  visible: boolean;
  menus: Record<string, MenuDefinition>;
  navigation: MenuNavigationState;
  itemStates: Record<string, Record<string, unknown>>;
  searchState: Record<string, SearchInfo>;
  expandedCategory: Record<string, string | null>;

  registerMenu: (menu: MenuDefinition) => void;
  removeMenu: (id: string) => void;
  addItem: (menuId: string, item: MenuItem) => void;
  removeItem: (menuId: string, itemId: string) => void;
  updateItem: (menuId: string, itemId: string, updates: Partial<MenuItem>) => void;
  openMenu: (id: string) => void;
  closeMenu: () => void;
  goBack: () => void;
  navigateToSubmenu: (menuId: string) => void;
  setActiveIndex: (menuId: string, index: number) => void;
  moveUp: () => void;
  moveDown: () => void;
  selectCurrent: () => void;
  getCurrentMenu: () => MenuDefinition | undefined;
  getCurrentIndex: () => number;
  toggleSearch: (menuId: string) => void;
  setSearchQuery: (menuId: string, query: string) => void;
  isSearchActive: () => boolean;
  toggleCategory: (menuId: string, categoryId: string) => void;
  getVisibleItems: (menuId: string) => MenuItem[];
}

export const useMenuStore = create<MenuStore>((set, get) => ({
  visible: false,
  menus: {},
  navigation: {
    stack: [],
    activeIndex: {},
    scrollOffset: {},
  },
  itemStates: {},
  searchState: {},
  expandedCategory: {},

  registerMenu: (menu) => {
    registry.registerMenu(menu);
    set((state) => ({
      menus: { ...state.menus, [menu.id]: menu },
    }));
  },

  removeMenu: (id) => {
    registry.removeMenu(id);
    set((state) => {
      const menus = { ...state.menus };
      delete menus[id];
      return { menus };
    });
  },

  addItem: (menuId, item) => {
    set((state) => {
      const menu = state.menus[menuId];
      if (!menu) return state;

      const savedState = state.itemStates[item.id];
      const restoredItem = savedState
        ? ({ ...item, ...savedState } as MenuItem)
        : item;

      return {
        menus: {
          ...state.menus,
          [menuId]: { ...menu, items: [...menu.items, restoredItem] },
        },
      };
    });
  },

  removeItem: (menuId, itemId) => {
    set((state) => {
      const menu = state.menus[menuId];
      if (!menu) return state;
      return {
        menus: {
          ...state.menus,
          [menuId]: {
            ...menu,
            items: menu.items.filter((i) => i.id !== itemId),
          },
        },
      };
    });
  },

  updateItem: (menuId, itemId, updates) => {
    set((state) => {
      const menu = state.menus[menuId];
      if (!menu) return state;
      return {
        menus: {
          ...state.menus,
          [menuId]: {
            ...menu,
            items: menu.items.map((i) =>
              i.id === itemId ? ({ ...i, ...updates } as MenuItem) : i,
            ),
          },
        },
        itemStates: {
          ...state.itemStates,
          [itemId]: { ...(state.itemStates[itemId] || {}), ...updates },
        },
      };
    });
  },

  openMenu: (id) => {
    const menu = get().menus[id];
    if (!menu) return;
    set((state) => ({
      visible: true,
      navigation: {
        stack: [id],
        activeIndex: {
          ...state.navigation.activeIndex,
          [id]: state.navigation.activeIndex[id] ?? 0,
        },
        scrollOffset: {
          ...state.navigation.scrollOffset,
          [id]: state.navigation.scrollOffset[id] ?? 0,
        },
      },
      expandedCategory: {
        ...state.expandedCategory,
        [id]: null,
      },
    }));
  },

  closeMenu: () => {
    Sound.back();
    const { navigation, searchState } = get();
    const currentMenuId = navigation.stack[navigation.stack.length - 1];
    if (currentMenuId && searchState[currentMenuId]?.active) {
      nuiCallback('zedlib:searchFocus', { active: false });
    }
    set({
      visible: false,
      searchState: {},
    });
    nuiCallback('zedlib:menuClosed');
  },

  goBack: () => {
    Sound.back();
    const { navigation, searchState } = get();
    if (navigation.stack.length <= 1) {
      get().closeMenu();
      return;
    }
    const leavingMenuId = navigation.stack[navigation.stack.length - 1];
    if (leavingMenuId && searchState[leavingMenuId]?.active) {
      nuiCallback('zedlib:searchFocus', { active: false });
    }
    const newStack = navigation.stack.slice(0, -1);
    const newSearch = { ...searchState };
    if (leavingMenuId) delete newSearch[leavingMenuId];
    set({
      navigation: { ...navigation, stack: newStack },
      searchState: newSearch,
    });
  },

  navigateToSubmenu: (menuId) => {
    const { navigation, menus, searchState } = get();
    if (!menus[menuId]) return;
    const currentMenuId = navigation.stack[navigation.stack.length - 1];
    if (currentMenuId && searchState[currentMenuId]?.active) {
      nuiCallback('zedlib:searchFocus', { active: false });
    }
    const newSearch = { ...searchState };
    if (currentMenuId) delete newSearch[currentMenuId];
    set({
      navigation: {
        ...navigation,
        stack: [...navigation.stack, menuId],
        activeIndex: { ...navigation.activeIndex, [menuId]: 0 },
        scrollOffset: { ...navigation.scrollOffset, [menuId]: 0 },
      },
      searchState: newSearch,
    });
  },

  setActiveIndex: (menuId, index) => {
    set((state) => ({
      navigation: {
        ...state.navigation,
        activeIndex: { ...state.navigation.activeIndex, [menuId]: index },
      },
    }));
  },

  getVisibleItems: (menuId) => {
    const { menus, expandedCategory, searchState } = get();
    const menu = menus[menuId];
    if (!menu) return [];
    const expanded = expandedCategory[menuId] ?? null;
    const byCategory = filterByCategory(menu.items, expanded);
    const search = searchState[menuId];
    const q = search?.active ? search.query.toLowerCase() : '';
    if (!q) return byCategory;
    // When searching: keep the search bar, but hide separators and only
    // include items whose label matches the query.
    return byCategory.filter(
      (i) =>
        i.type === 'search' ||
        ('label' in i && i.label.toLowerCase().includes(q))
    );
  },

  toggleCategory: (menuId, categoryId) => {
    set((state) => {
      const current = state.expandedCategory[menuId] ?? null;
      const next = current === categoryId ? null : categoryId;
      return {
        expandedCategory: {
          ...state.expandedCategory,
          [menuId]: next,
        },
      };
    });
  },

  moveUp: () => {
    const { navigation, getVisibleItems } = get();
    const currentMenuId = navigation.stack[navigation.stack.length - 1];
    if (!currentMenuId) return;
    const filtered = getVisibleItems(currentMenuId);
    const selectableItems = filtered.filter((i) => i.type !== 'separator');
    const currentIndex = navigation.activeIndex[currentMenuId] ?? 0;
    const newIndex = currentIndex <= 0 ? selectableItems.length - 1 : currentIndex - 1;
    Sound.hover();

    set((state) => ({
      navigation: {
        ...state.navigation,
        activeIndex: { ...state.navigation.activeIndex, [currentMenuId]: newIndex },
      },
    }));
  },

  moveDown: () => {
    const { navigation, getVisibleItems } = get();
    const currentMenuId = navigation.stack[navigation.stack.length - 1];
    if (!currentMenuId) return;
    const filtered = getVisibleItems(currentMenuId);
    const selectableItems = filtered.filter((i) => i.type !== 'separator');
    const currentIndex = navigation.activeIndex[currentMenuId] ?? 0;
    const newIndex = currentIndex >= selectableItems.length - 1 ? 0 : currentIndex + 1;
    Sound.hover();

    set((state) => ({
      navigation: {
        ...state.navigation,
        activeIndex: { ...state.navigation.activeIndex, [currentMenuId]: newIndex },
      },
    }));
  },

  selectCurrent: () => {
    const { navigation, getVisibleItems, searchState } = get();
    const currentMenuId = navigation.stack[navigation.stack.length - 1];
    if (!currentMenuId) return;

    const filtered = getVisibleItems(currentMenuId);
    const selectableItems = filtered.filter((i) => i.type !== 'separator');
    const currentIndex = navigation.activeIndex[currentMenuId] ?? 0;
    const item = selectableItems[currentIndex];
    if (!item || ('disabled' in item && item.disabled)) return;

    if (item.type !== 'search' && searchState[currentMenuId]?.active) {
      nuiCallback('zedlib:searchFocus', { active: false });
      const newSearch = { ...get().searchState };
      delete newSearch[currentMenuId];
      set({ searchState: newSearch });
    }

    switch (item.type) {
      case 'search':
        Sound.select();
        get().toggleSearch(currentMenuId);
        break;
      case 'category':
        Sound.select();
        get().toggleCategory(currentMenuId, item.id);
        break;
      case 'button':
        Sound.select();
        if (item.onSelect) {
          nuiCallback('zedlib:menuAction', {
            action: item.onSelect,
            menuId: currentMenuId,
            itemId: item.id,
            metadata: item.metadata,
          });
        }
        break;
      case 'checkbox': {
        Sound.toggle();
        const newChecked = !item.checked;
        get().updateItem(currentMenuId, item.id, { checked: newChecked });
        if (item.onChange) {
          nuiCallback('zedlib:menuAction', {
            action: item.onChange,
            menuId: currentMenuId,
            itemId: item.id,
            checked: newChecked,
          });
        }
        break;
      }
      case 'submenu':
        Sound.select();
        get().navigateToSubmenu(item.targetMenu);
        break;
      case 'list': {
        Sound.hover();
        const nextIndex = (item.currentIndex + 1) % item.items.length;
        get().updateItem(currentMenuId, item.id, { currentIndex: nextIndex });
        if (item.onChange) {
          nuiCallback('zedlib:menuAction', {
            action: item.onChange,
            menuId: currentMenuId,
            itemId: item.id,
            value: item.items[nextIndex],
            index: nextIndex,
          });
        }
        break;
      }
    }
  },

  getCurrentMenu: () => {
    const { navigation, menus } = get();
    const currentMenuId = navigation.stack[navigation.stack.length - 1];
    return currentMenuId ? menus[currentMenuId] : undefined;
  },

  getCurrentIndex: () => {
    const { navigation } = get();
    const currentMenuId = navigation.stack[navigation.stack.length - 1];
    return currentMenuId ? (navigation.activeIndex[currentMenuId] ?? 0) : 0;
  },

  toggleSearch: (menuId) => {
    const { searchState } = get();
    const wasActive = searchState[menuId]?.active ?? false;
    const nowActive = !wasActive;

    set((state) => ({
      searchState: {
        ...state.searchState,
        [menuId]: { active: nowActive, query: '' },
      },
      navigation: {
        ...state.navigation,
        activeIndex: { ...state.navigation.activeIndex, [menuId]: 0 },
      },
    }));

    nuiCallback('zedlib:searchFocus', { active: nowActive });
  },

  setSearchQuery: (menuId, query) => {
    set((state) => ({
      searchState: {
        ...state.searchState,
        [menuId]: { ...(state.searchState[menuId] || { active: true }), query },
      },
      navigation: {
        ...state.navigation,
        activeIndex: { ...state.navigation.activeIndex, [menuId]: 0 },
      },
    }));
  },

  isSearchActive: () => {
    const { navigation, searchState } = get();
    const currentMenuId = navigation.stack[navigation.stack.length - 1];
    return currentMenuId ? (searchState[currentMenuId]?.active ?? false) : false;
  },
}));

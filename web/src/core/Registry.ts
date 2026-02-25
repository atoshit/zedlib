import type { MenuDefinition } from '@/types';

class ComponentRegistry {
  private menus = new Map<string, MenuDefinition>();

  registerMenu(menu: MenuDefinition): void {
    this.menus.set(menu.id, menu);
  }

  getMenu(id: string): MenuDefinition | undefined {
    return this.menus.get(id);
  }

  removeMenu(id: string): void {
    this.menus.delete(id);
  }

  getAllMenus(): MenuDefinition[] {
    return Array.from(this.menus.values());
  }

  clear(): void {
    this.menus.clear();
  }
}

export const registry = new ComponentRegistry();

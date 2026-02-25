export type MenuItemType = 'button' | 'checkbox' | 'separator' | 'submenu' | 'slider' | 'list' | 'search';

export interface MenuItemBase {
  id: string;
  type: MenuItemType;
  label: string;
  description?: string;
  disabled?: boolean;
  icon?: string;
}

export interface MenuButton extends MenuItemBase {
  type: 'button';
  onSelect?: string;
  metadata?: Record<string, unknown>;
}

export interface MenuCheckbox extends MenuItemBase {
  type: 'checkbox';
  checked: boolean;
  onChange?: string;
}

export interface MenuSeparator {
  id: string;
  type: 'separator';
}

export interface MenuSubmenu extends MenuItemBase {
  type: 'submenu';
  targetMenu: string;
}

export interface MenuSlider extends MenuItemBase {
  type: 'slider';
  min: number;
  max: number;
  step: number;
  value: number;
  onChange?: string;
}

export interface MenuListItem {
  label: string;
  value: string;
  description?: string;
}

export interface MenuList extends MenuItemBase {
  type: 'list';
  items: MenuListItem[];
  currentIndex: number;
  onChange?: string;
}

export interface MenuSearchItem extends MenuItemBase {
  type: 'search';
  placeholder?: string;
}

export type MenuItem = MenuButton | MenuCheckbox | MenuSeparator | MenuSubmenu | MenuSlider | MenuList | MenuSearchItem;

export interface MenuDefinition {
  id: string;
  title: string;
  subtitle?: string;
  color?: string;
  items: MenuItem[];
  position?: 'left' | 'center' | 'right';
  banner?: string;
  maxVisibleItems?: number;
}

export interface MenuNavigationState {
  stack: string[];
  activeIndex: Record<string, number>;
  scrollOffset: Record<string, number>;
}

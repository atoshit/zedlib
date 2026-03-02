export type MenuItemType = 'button' | 'checkbox' | 'separator' | 'submenu' | 'slider' | 'list' | 'search' | 'info' | 'category';

export interface MenuItemBase {
  id: string;
  type: MenuItemType;
  label: string;
  description?: string;
  disabled?: boolean;
  icon?: string;
  /** If set, this item is only visible when the category with this id is expanded */
  category?: string;
  /** Info data displayed in a side panel when this item is focused */
  infoData?: MenuInfoData[];
}

export interface MenuButton extends MenuItemBase {
  type: 'button';
  onSelect?: string;
  metadata?: Record<string, unknown>;
  rightLabel?: string;
  rightLabelColor?: string;
}

export interface MenuCheckbox extends MenuItemBase {
  type: 'checkbox';
  checked: boolean;
  onChange?: string;
}

export interface MenuSeparator {
  id: string;
  type: 'separator';
  description?: string;
  category?: string;
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

export interface MenuInfoData {
  label: string;
  value: string;
}

export interface MenuInfoButton extends MenuItemBase {
  type: 'info';
  infoData: MenuInfoData[];
}

/** Category header: when selected, toggles visibility of items that have category === this item's id */
export interface MenuCategory {
  id: string;
  type: 'category';
  label: string;
  description?: string;
  icon?: string;
  disabled?: boolean;
  infoData?: MenuInfoData[];
}

export type MenuItem = MenuButton | MenuCheckbox | MenuSeparator | MenuSubmenu | MenuSlider | MenuList | MenuSearchItem | MenuInfoButton | MenuCategory;

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

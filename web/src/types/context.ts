export interface ContextOption {
  id: string;
  label: string;
  icon?: string;
  disabled?: boolean;
  onSelect?: string;
  children?: ContextOption[];
}

export interface ContextSubMenu {
  id: string;
  label: string;
  icon?: string;
  children: ContextOption[];
}

export interface ContextMenuData {
  options: ContextOption[];
  entityType: string;
  entityId: number;
  position: { x: number; y: number };
}

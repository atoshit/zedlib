export type DialogType = 'confirm' | 'input' | 'custom';

export interface DialogButton {
  label: string;
  variant?: 'primary' | 'secondary' | 'danger';
  action: string;
  icon?: string;
  /** Optional custom background color (hex or rgba). Overrides variant background. */
  backgroundColor?: string;
}

export interface DialogSelectOption {
  value: string;
  label: string;
}

export interface DialogInputField {
  id: string;
  type: 'text' | 'number' | 'password' | 'textarea' | 'date' | 'select' | 'multiselect' | 'checkbox';
  label: string;
  placeholder?: string;
  /** Default value. For checkbox use 'true'/'false'. For multiselect use JSON array string e.g. '["v1","v2"]'. */
  defaultValue?: string;
  required?: boolean;
  maxLength?: number;
  min?: number;
  max?: number;
  /** Options for select and multiselect. */
  options?: DialogSelectOption[];
  /** Checkbox label when type is 'checkbox' (field label is above). */
  checkboxLabel?: string;
}

export interface DialogData {
  id: string;
  type: DialogType;
  title: string;
  message?: string;
  inputs?: DialogInputField[];
  buttons?: DialogButton[];
  closable?: boolean;
  color?: string;
  icon?: string;
}

export interface DialogResult {
  dialogId: string;
  action: string;
  values?: Record<string, string>;
}

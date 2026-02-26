export type DialogType = 'confirm' | 'input' | 'custom';

export interface DialogButton {
  label: string;
  variant?: 'primary' | 'secondary' | 'danger';
  action: string;
  icon?: string;
}

export interface DialogInputField {
  id: string;
  type: 'text' | 'number' | 'password' | 'textarea';
  label: string;
  placeholder?: string;
  defaultValue?: string;
  required?: boolean;
  maxLength?: number;
  min?: number;
  max?: number;
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

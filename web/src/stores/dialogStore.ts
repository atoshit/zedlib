import { create } from 'zustand';
import type { DialogData, DialogResult } from '@/types';
import { nuiCallback } from '@/nui';

interface DialogStore {
  activeDialog: DialogData | null;
  inputValues: Record<string, string>;

  openDialog: (dialog: DialogData) => void;
  closeDialog: () => void;
  setInputValue: (fieldId: string, value: string) => void;
  submitDialog: (action: string) => void;
}

export const useDialogStore = create<DialogStore>((set, get) => ({
  activeDialog: null,
  inputValues: {},

  openDialog: (dialog) => {
    const initialValues: Record<string, string> = {};
    if (dialog.inputs) {
      for (const input of dialog.inputs) {
        initialValues[input.id] = input.defaultValue ?? (input.type === 'checkbox' ? 'false' : '');
      }
    }
    set({ activeDialog: dialog, inputValues: initialValues });
  },

  closeDialog: () => {
    set({ activeDialog: null, inputValues: {} });
  },

  setInputValue: (fieldId, value) => {
    set((state) => ({
      inputValues: { ...state.inputValues, [fieldId]: value },
    }));
  },

  submitDialog: (action) => {
    const { activeDialog, inputValues } = get();
    if (!activeDialog) return;

    const result: DialogResult = {
      dialogId: activeDialog.id,
      action,
      values: inputValues,
    };

    nuiCallback('zedlib:dialogResult', result);
    get().closeDialog();
  },
}));

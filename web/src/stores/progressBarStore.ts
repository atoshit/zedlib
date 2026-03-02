import { create } from 'zustand';

export interface ProgressBarData {
  label: string;
  duration: number;
  canCancel: boolean;
}

interface ProgressBarStore {
  active: boolean;
  data: ProgressBarData | null;
  startTime: number;
  show: (data: ProgressBarData) => void;
  hide: () => void;
}

export const useProgressBarStore = create<ProgressBarStore>((set) => ({
  active: false,
  data: null,
  startTime: 0,
  show: (data) =>
    set({
      active: true,
      data,
      startTime: Date.now(),
    }),
  hide: () =>
    set({
      active: false,
      data: null,
      startTime: 0,
    }),
}));

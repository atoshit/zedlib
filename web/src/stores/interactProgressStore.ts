import { create } from 'zustand';

export interface InteractProgressData {
  x: number;
  y: number;
  label: string;
  key?: string;
  duration: number;
}

interface InteractProgressStore {
  visible: boolean;
  data: InteractProgressData | null;
  progress: number;
  keyPressed: boolean;
  show: (data: InteractProgressData) => void;
  hide: () => void;
  updatePosition: (x: number, y: number) => void;
  setProgress: (p: number) => void;
  setKeyPressed: (p: boolean) => void;
}

export const useInteractProgressStore = create<InteractProgressStore>((set) => ({
  visible: false,
  data: null,
  progress: 0,
  keyPressed: false,
  show: (data) => set({ visible: true, data, progress: 0, keyPressed: false }),
  hide: () => set({ visible: false, data: null, progress: 0, keyPressed: false }),
  updatePosition: (x, y) =>
    set((state) =>
      state.data ? { data: { ...state.data, x, y } } : state
    ),
  setProgress: (progress) => set({ progress }),
  setKeyPressed: (keyPressed) => set({ keyPressed }),
}));

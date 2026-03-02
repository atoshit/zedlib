import { create } from 'zustand';

export interface InteractData {
  /** Screen position 0-1 (from Lua GetScreenCoordFromWorldCoord) */
  x: number;
  y: number;
  label: string;
  /** Key to show (e.g. 'E'). If not set, no key box is shown */
  key?: string;
}

interface InteractStore {
  visible: boolean;
  data: InteractData | null;
  keyPressed: boolean;
  show: (data: InteractData) => void;
  hide: () => void;
  updatePosition: (x: number, y: number) => void;
  setKeyPressed: (pressed: boolean) => void;
}

export const useInteractStore = create<InteractStore>((set) => ({
  visible: false,
  data: null,
  keyPressed: false,
  show: (data) => set({ visible: true, data, keyPressed: false }),
  hide: () => set({ visible: false, data: null, keyPressed: false }),
  updatePosition: (x, y) =>
    set((state) =>
      state.data ? { data: { ...state.data, x, y } } : state
    ),
  setKeyPressed: (keyPressed) => set({ keyPressed }),
}));

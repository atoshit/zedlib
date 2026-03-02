import { create } from 'zustand';

interface ZedLibConfig {
  sounds: boolean;
  accentColor: string;
  showTitle: boolean;
  showItemCount: boolean;
}

interface ConfigStore {
  config: ZedLibConfig;
  setConfig: (partial: Partial<ZedLibConfig>) => void;
}

export const useConfigStore = create<ConfigStore>((set) => ({
  config: {
    sounds: true,
    accentColor: '#e74c3c',
    showTitle: true,
    showItemCount: true,
  },
  setConfig: (partial) =>
    set((state) => ({
      config: { ...state.config, ...partial },
    })),
}));

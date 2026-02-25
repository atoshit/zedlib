import { create } from 'zustand';

interface ZedLibConfig {
  sounds: boolean;
}

interface ConfigStore {
  config: ZedLibConfig;
  setConfig: (partial: Partial<ZedLibConfig>) => void;
}

export const useConfigStore = create<ConfigStore>((set) => ({
  config: {
    sounds: true,
  },
  setConfig: (partial) =>
    set((state) => ({
      config: { ...state.config, ...partial },
    })),
}));

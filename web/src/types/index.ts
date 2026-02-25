export * from './menu';
export * from './notification';
export * from './dialog';

export interface NuiMessage<T = unknown> {
  action: string;
  data: T;
}

export interface PluginDefinition {
  name: string;
  version: string;
  init: () => void;
  destroy?: () => void;
  components?: Record<string, React.ComponentType>;
}

export interface ZedLibConfig {
  resourceName: string;
  debug: boolean;
  defaultMenuPosition: 'left' | 'center' | 'right';
  notificationConfig: {
    defaultDuration: number;
    maxVisible: number;
    position: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left';
  };
}

import type { PluginDefinition } from '@/types';

class PluginSystem {
  private plugins = new Map<string, PluginDefinition>();

  register(plugin: PluginDefinition): void {
    if (this.plugins.has(plugin.name)) {
      console.warn(`[ZedLib] Plugin "${plugin.name}" already registered, replacing.`);
      this.plugins.get(plugin.name)?.destroy?.();
    }
    this.plugins.set(plugin.name, plugin);
    plugin.init();
    console.log(`[ZedLib] Plugin "${plugin.name}" v${plugin.version} loaded.`);
  }

  unregister(name: string): void {
    const plugin = this.plugins.get(name);
    if (plugin) {
      plugin.destroy?.();
      this.plugins.delete(name);
    }
  }

  get(name: string): PluginDefinition | undefined {
    return this.plugins.get(name);
  }

  getAll(): PluginDefinition[] {
    return Array.from(this.plugins.values());
  }

  destroy(): void {
    for (const plugin of this.plugins.values()) {
      plugin.destroy?.();
    }
    this.plugins.clear();
  }
}

export const pluginSystem = new PluginSystem();

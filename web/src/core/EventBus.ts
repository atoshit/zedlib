type EventHandler<T = unknown> = (data: T) => void;

interface EventSubscription {
  id: string;
  handler: EventHandler;
}

class EventBus {
  private listeners = new Map<string, EventSubscription[]>();
  private idCounter = 0;

  on<T = unknown>(event: string, handler: EventHandler<T>): () => void {
    const id = `sub_${++this.idCounter}`;
    const subscription: EventSubscription = { id, handler: handler as EventHandler };

    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event)!.push(subscription);

    return () => this.off(event, id);
  }

  once<T = unknown>(event: string, handler: EventHandler<T>): () => void {
    const unsubscribe = this.on<T>(event, (data) => {
      handler(data);
      unsubscribe();
    });
    return unsubscribe;
  }

  emit<T = unknown>(event: string, data: T): void {
    const subs = this.listeners.get(event);
    if (!subs) return;
    for (const sub of [...subs]) {
      try {
        sub.handler(data);
      } catch (err) {
        console.error(`[ZedLib] EventBus error in "${event}":`, err);
      }
    }
  }

  private off(event: string, id: string): void {
    const subs = this.listeners.get(event);
    if (!subs) return;
    const idx = subs.findIndex((s) => s.id === id);
    if (idx !== -1) subs.splice(idx, 1);
    if (subs.length === 0) this.listeners.delete(event);
  }

  clear(): void {
    this.listeners.clear();
  }
}

export const eventBus = new EventBus();
export type { EventHandler };

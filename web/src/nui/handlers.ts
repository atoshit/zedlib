import { eventBus } from '@/core';
import type { NuiMessage } from '@/types';

type MessageRouter = Record<string, (data: unknown) => void>;

let messageRouter: MessageRouter = {};

export function registerNuiHandler(action: string, handler: (data: unknown) => void): void {
  messageRouter[action] = handler;
}

export function removeNuiHandler(action: string): void {
  delete messageRouter[action];
}

export function dispatchNuiAction(action: string, data: unknown): void {
  const handler = messageRouter[action];
  if (handler) handler(data);
}

function handleNuiMessage(event: MessageEvent<NuiMessage>): void {
  const { action, data } = event.data ?? {};
  if (!action) return;

  const handler = messageRouter[action];
  if (handler) {
    handler(data);
  }

  eventBus.emit(`nui:${action}`, data);
}

export function initNuiListeners(): void {
  window.addEventListener('message', handleNuiMessage);
}

export function destroyNuiListeners(): void {
  window.removeEventListener('message', handleNuiMessage);
  messageRouter = {};
}

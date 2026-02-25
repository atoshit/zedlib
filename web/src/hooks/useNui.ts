import { useEffect, useRef } from 'react';
import type { NuiMessage } from '@/types';

export function useNuiEvent<T = unknown>(
  action: string,
  handler: (data: T) => void,
): void {
  const savedHandler = useRef(handler);
  savedHandler.current = handler;

  useEffect(() => {
    function onMessage(event: MessageEvent<NuiMessage<T>>) {
      const { action: msgAction, data } = event.data ?? {};
      if (msgAction === action) {
        savedHandler.current(data);
      }
    }

    window.addEventListener('message', onMessage);
    return () => window.removeEventListener('message', onMessage);
  }, [action]);
}

import { useEffect, useRef } from 'react';

type KeyMap = Record<string, () => void>;

export function useKeyboard(keyMap: KeyMap, enabled = true): void {
  const keyMapRef = useRef(keyMap);
  keyMapRef.current = keyMap;

  useEffect(() => {
    if (!enabled) return;

    function handleKeyDown(e: KeyboardEvent) {
      const handler = keyMapRef.current[e.key];
      if (handler) {
        e.preventDefault();
        e.stopPropagation();
        handler();
      }
    }

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [enabled]);
}

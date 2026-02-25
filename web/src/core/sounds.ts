import { useConfigStore } from '@/stores/configStore';

const pool: Record<string, HTMLAudioElement[]> = {};
const POOL_SIZE = 4;

function ensurePool(name: string) {
  if (pool[name]) return;
  pool[name] = [];
  for (let i = 0; i < POOL_SIZE; i++) {
    const audio = new Audio(`./sounds/${name}`);
    audio.preload = 'auto';
    pool[name].push(audio);
  }
}

function play(name: string, volume: number) {
  if (!useConfigStore.getState().config.sounds) return;
  try {
    ensurePool(name);
    const available = pool[name].find((a) => a.paused || a.ended);
    const audio = available ?? pool[name][0];
    audio.volume = volume;
    audio.currentTime = 0;
    audio.play().catch(() => {});
  } catch {
    // ignore
  }
}

export const Sound = {
  hover: () => play('hover.wav', 0.15),
  select: () => play('select.wav', 0.25),
  back: () => {},
  toggle: () => play('toggle.wav', 0.25),
};

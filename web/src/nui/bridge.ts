const isEnvFiveM = (): boolean => {
  return typeof (window as unknown as Record<string, unknown>).GetParentResourceName === 'function';
};

export const getResourceName = (): string => {
  if (isEnvFiveM()) {
    return (window as unknown as { GetParentResourceName: () => string }).GetParentResourceName();
  }
  return 'zedlib';
};

export const isFiveM = isEnvFiveM();

export async function nuiCallback<T = unknown>(
  event: string,
  data: unknown = {},
): Promise<T> {
  if (!isFiveM) {
    console.log(`[ZedLib:Dev] NUI Callback → ${event}`, data);
    return {} as T;
  }

  const resourceName = getResourceName();

  try {
    const response = await fetch(`https://${resourceName}/${event}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    return await response.json();
  } catch (err) {
    console.error(`[ZedLib] NUI callback "${event}" failed:`, err);
    return {} as T;
  }
}

export function sendReactMessage(action: string, data: unknown = {}): void {
  window.dispatchEvent(
    new MessageEvent('message', {
      data: { action, data },
    }),
  );
}

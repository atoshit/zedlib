import { useEffect } from 'react';
import { Menu } from '@/components/menu';
import { NotificationContainer } from '@/components/notification';
import { Dialog } from '@/components/dialog';
import { ContextMenu } from '@/components/context';
import { initNuiListeners, destroyNuiListeners, isFiveM } from '@/nui';
import { registerAllHandlers } from '@/nui/messageHandlers';
import { Playground } from '@/devtools/Playground';

export function App() {
  useEffect(() => {
    initNuiListeners();
    registerAllHandlers();
    return () => destroyNuiListeners();
  }, []);

  return (
    <div className="w-screen h-screen relative">
      <Menu />
      <NotificationContainer />
      <Dialog />
      <ContextMenu />
      {!isFiveM && <Playground />}
    </div>
  );
}

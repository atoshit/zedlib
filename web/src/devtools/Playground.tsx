import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { MenuTester } from './MenuTester';
import { NotificationTester } from './NotificationTester';
import { DialogTester } from './DialogTester';
import { NuiSimulator } from './NuiSimulator';

type Tab = 'menu' | 'notification' | 'dialog' | 'nui';

const tabs: { id: Tab; label: string }[] = [
  { id: 'menu', label: 'Menu' },
  { id: 'notification', label: 'Notifications' },
  { id: 'dialog', label: 'Dialog' },
  { id: 'nui', label: 'NUI Sim' },
];

export function Playground() {
  const [open, setOpen] = useState(true);
  const [activeTab, setActiveTab] = useState<Tab>('menu');

  return (
    <>
      <button
        onClick={() => setOpen((v) => !v)}
        className="fixed bottom-4 right-4 z-[200] bg-zed-accent hover:bg-zed-accent-hover text-white px-4 py-2 rounded-lg text-sm font-semibold shadow-xl shadow-zed-accent/20 transition-all"
      >
        {open ? '✕ Fermer' : '⚡ DevTools'}
      </button>

      <AnimatePresence>
        {open && (
          <motion.div
            className="fixed bottom-14 right-4 z-[190] w-[380px] max-h-[600px] bg-[#0a0a0a] rounded-xl border border-white/10 shadow-2xl shadow-black/60 overflow-hidden flex flex-col"
            initial={{ opacity: 0, y: 20, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 20, scale: 0.95 }}
            transition={{ type: 'spring', stiffness: 400, damping: 30 }}
          >
            <div className="px-4 py-3 border-b border-white/10">
              <h3 className="text-sm font-bold text-white flex items-center gap-2">
                <span className="text-zed-accent">⚡</span>
                ZedLib Playground
              </h3>
              <p className="text-[10px] text-white/40 mt-0.5">
                Test components & simulate NUI events
              </p>
            </div>

            <div className="flex border-b border-white/10">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`
                    flex-1 px-3 py-2 text-[11px] font-medium transition-all
                    ${activeTab === tab.id
                      ? 'text-zed-accent border-b-2 border-zed-accent bg-zed-accent/5'
                      : 'text-white/40 hover:text-white/60'
                    }
                  `}
                >
                  {tab.label}
                </button>
              ))}
            </div>

            <div className="flex-1 overflow-y-auto p-4 scrollbar-thin">
              {activeTab === 'menu' && <MenuTester />}
              {activeTab === 'notification' && <NotificationTester />}
              {activeTab === 'dialog' && <DialogTester />}
              {activeTab === 'nui' && <NuiSimulator />}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}

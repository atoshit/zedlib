import { AnimatePresence, motion } from 'framer-motion';
import { useDialogStore } from '@/stores';
import { useKeyboard } from '@/hooks';

export function Dialog() {
  const { activeDialog, inputValues, setInputValue, submitDialog, closeDialog } = useDialogStore();

  useKeyboard(
    {
      Escape: () => {
        if (activeDialog?.closable !== false) closeDialog();
      },
    },
    !!activeDialog,
  );

  return (
    <AnimatePresence>
      {activeDialog && (
        <motion.div
          className="fixed inset-0 z-[90] flex items-center justify-center"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.15 }}
        >
          <motion.div
            className="absolute inset-0 bg-black/70"
            onClick={() => activeDialog.closable !== false && closeDialog()}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          />

          <motion.div
            className="relative w-[420px] bg-[#0a0a0a] rounded-xl border border-white/10 shadow-2xl shadow-black/60 overflow-hidden"
            initial={{ opacity: 0, scale: 0.92, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.92, y: 20 }}
            transition={{ type: 'spring', stiffness: 400, damping: 30 }}
          >
            <div className="px-6 pt-5 pb-3">
              <h3 className="text-base font-semibold text-white">{activeDialog.title}</h3>
              {activeDialog.message && (
                <p className="text-[13px] text-white/60 mt-1.5 leading-relaxed">
                  {activeDialog.message}
                </p>
              )}
            </div>

            {activeDialog.inputs && activeDialog.inputs.length > 0 && (
              <div className="px-6 py-3 space-y-3">
                {activeDialog.inputs.map((input) => (
                  <div key={input.id}>
                    <label className="block text-[12px] font-medium text-white/60 mb-1.5">
                      {input.label}
                      {input.required && <span className="text-red-400 ml-0.5">*</span>}
                    </label>
                    {input.type === 'textarea' ? (
                      <textarea
                        className="w-full bg-black/50 border border-white/10 rounded-lg px-3 py-2 text-[13px] text-white placeholder-white/20 focus:outline-none focus:border-zed-accent focus:ring-1 focus:ring-zed-accent/30 transition-all resize-none"
                        placeholder={input.placeholder}
                        value={inputValues[input.id] ?? ''}
                        onChange={(e) => setInputValue(input.id, e.target.value)}
                        maxLength={input.maxLength}
                        rows={3}
                        autoFocus
                      />
                    ) : (
                      <input
                        type={input.type}
                        className="w-full bg-black/50 border border-white/10 rounded-lg px-3 py-2 text-[13px] text-white placeholder-white/20 focus:outline-none focus:border-zed-accent focus:ring-1 focus:ring-zed-accent/30 transition-all"
                        placeholder={input.placeholder}
                        value={inputValues[input.id] ?? ''}
                        onChange={(e) => setInputValue(input.id, e.target.value)}
                        maxLength={input.maxLength}
                        min={input.min}
                        max={input.max}
                        autoFocus
                      />
                    )}
                  </div>
                ))}
              </div>
            )}

            <div className="px-6 py-4 flex items-center justify-end gap-2 border-t border-white/10">
              {(activeDialog.buttons ?? [
                { label: 'Annuler', variant: 'secondary', action: 'cancel' },
                { label: 'Confirmer', variant: 'primary', action: 'confirm' },
              ]).map((btn) => (
                <button
                  key={btn.action}
                  onClick={() => submitDialog(btn.action)}
                  className={`
                    px-4 py-2 rounded-lg text-[13px] font-medium transition-all duration-150
                    ${btn.variant === 'primary'
                      ? 'bg-zed-accent hover:bg-zed-accent-hover text-white shadow-lg shadow-zed-accent/20'
                      : btn.variant === 'danger'
                        ? 'bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20'
                        : 'bg-white/5 hover:bg-white/10 text-white/70 border border-white/10'
                    }
                  `}
                >
                  {btn.label}
                </button>
              ))}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

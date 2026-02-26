import { AnimatePresence, motion } from 'framer-motion';
import { useDialogStore } from '@/stores';
import { useKeyboard } from '@/hooks';

const DEFAULT_COLOR = '#e74c3c';

export function Dialog() {
  const { activeDialog, inputValues, setInputValue, submitDialog, closeDialog } = useDialogStore();
  const accentColor = activeDialog?.color || DEFAULT_COLOR;

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
          transition={{ duration: 0.2 }}
        >
          <div
            className="absolute inset-0"
            onClick={() => activeDialog.closable !== false && closeDialog()}
          />

          <motion.div
            className="relative w-[420px] rounded-xl overflow-hidden"
            style={{
              backgroundColor: 'rgba(0, 0, 0, 0.80)',
            }}
            initial={{ opacity: 0, scale: 0.9, y: 30 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 30 }}
            transition={{ type: 'spring', stiffness: 400, damping: 30 }}
          >
            <div className="h-[3px]" style={{ backgroundColor: accentColor }} />

            <div className="px-6 pt-5 pb-3">
              <div className="flex items-start gap-3">
                {activeDialog.icon && (
                  <div
                    className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
                    style={{ backgroundColor: `${accentColor}20` }}
                  >
                    <i
                      className={`fa-solid fa-${activeDialog.icon} text-lg`}
                      style={{ color: accentColor }}
                    />
                  </div>
                )}
                <div className="flex-1">
                  <h3 className="text-base font-semibold text-white">{activeDialog.title}</h3>
                  {activeDialog.message && (
                    <p className="text-[13px] text-white/50 mt-1 leading-relaxed">
                      {activeDialog.message}
                    </p>
                  )}
                </div>
              </div>
            </div>

            {activeDialog.inputs && activeDialog.inputs.length > 0 && (
              <div className="px-6 py-3 space-y-3">
                {activeDialog.inputs.map((input) => (
                  <div key={input.id}>
                    <label className="block text-[12px] font-medium text-white/50 mb-1.5">
                      {input.label}
                      {input.required && <span className="text-red-400 ml-0.5">*</span>}
                    </label>
                    {input.type === 'textarea' ? (
                      <textarea
                        className="w-full bg-white/5 border border-white/10 rounded-lg px-3 py-2.5 text-[13px] text-white placeholder-white/20 focus:outline-none transition-all resize-none"
                        style={{
                          borderColor: undefined,
                        }}
                        onFocus={(e) => {
                          e.target.style.borderColor = accentColor;
                          e.target.style.boxShadow = `0 0 0 1px ${accentColor}40`;
                        }}
                        onBlur={(e) => {
                          e.target.style.borderColor = 'rgba(255,255,255,0.1)';
                          e.target.style.boxShadow = 'none';
                        }}
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
                        className="w-full bg-white/5 border border-white/10 rounded-lg px-3 py-2.5 text-[13px] text-white placeholder-white/20 focus:outline-none transition-all"
                        onFocus={(e) => {
                          e.target.style.borderColor = accentColor;
                          e.target.style.boxShadow = `0 0 0 1px ${accentColor}40`;
                        }}
                        onBlur={(e) => {
                          e.target.style.borderColor = 'rgba(255,255,255,0.1)';
                          e.target.style.boxShadow = 'none';
                        }}
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

            <div className="px-6 py-4 flex items-center justify-end gap-2 border-t border-white/[0.06]">
              {(activeDialog.buttons ?? [
                { label: 'Cancel', variant: 'secondary' as const, action: 'cancel' },
                { label: 'Confirm', variant: 'primary' as const, action: 'confirm' },
              ]).map((btn) => {
                const isPrimary = btn.variant === 'primary';
                const isDanger = btn.variant === 'danger';

                return (
                  <button
                    key={btn.action}
                    onClick={() => submitDialog(btn.action)}
                    className="btn-shine px-4 py-2 rounded-lg text-[13px] font-medium transition-all duration-200"
                    style={
                      isPrimary
                        ? {
                            backgroundColor: accentColor,
                            color: 'white',
                            boxShadow: `0 0 15px ${accentColor}30`,
                          }
                        : isDanger
                          ? {
                              backgroundColor: 'rgba(239, 68, 68, 0.1)',
                              color: '#f87171',
                              border: '1px solid rgba(239, 68, 68, 0.2)',
                            }
                          : {
                              backgroundColor: 'rgba(255, 255, 255, 0.05)',
                              color: 'rgba(255, 255, 255, 0.7)',
                              border: '1px solid rgba(255, 255, 255, 0.1)',
                            }
                    }
                    onMouseEnter={(e) => {
                      if (isPrimary) {
                        e.currentTarget.style.boxShadow = `0 0 25px ${accentColor}50`;
                        e.currentTarget.style.filter = 'brightness(1.2)';
                      } else if (isDanger) {
                        e.currentTarget.style.backgroundColor = 'rgba(239, 68, 68, 0.2)';
                        e.currentTarget.style.boxShadow = '0 0 15px rgba(239, 68, 68, 0.15)';
                      } else {
                        e.currentTarget.style.backgroundColor = 'rgba(255, 255, 255, 0.1)';
                      }
                    }}
                    onMouseLeave={(e) => {
                      if (isPrimary) {
                        e.currentTarget.style.boxShadow = `0 0 15px ${accentColor}30`;
                        e.currentTarget.style.filter = 'brightness(1)';
                      } else if (isDanger) {
                        e.currentTarget.style.backgroundColor = 'rgba(239, 68, 68, 0.1)';
                        e.currentTarget.style.boxShadow = 'none';
                      } else {
                        e.currentTarget.style.backgroundColor = 'rgba(255, 255, 255, 0.05)';
                      }
                    }}
                  >
                    {btn.icon && <i className={`fa-solid fa-${btn.icon} mr-2 text-xs`} />}
                    {btn.label}
                  </button>
                );
              })}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

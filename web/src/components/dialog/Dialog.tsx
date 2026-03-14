import { useState, useRef, useEffect } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { useDialogStore, useConfigStore } from '@/stores';
import { useKeyboard } from '@/hooks';
import type { DialogInputField } from '@/types';

const inputBaseClass =
  'w-full bg-white/5 border border-white/10 rounded-lg px-3 py-2.5 text-[13px] text-white placeholder-white/20 focus:outline-none transition-all';
const inputFocusStyle = (accent: string) => ({
  onFocus: (e: React.FocusEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    e.target.style.borderColor = accent;
    e.target.style.boxShadow = `0 0 0 1px ${accent}40`;
  },
  onBlur: (e: React.FocusEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    e.target.style.borderColor = 'rgba(255,255,255,0.1)';
    e.target.style.boxShadow = 'none';
  },
});

function DialogInputField({
  input,
  value,
  setValue,
  accentColor,
  openSelectId,
  setOpenSelectId,
  selectRef,
}: {
  input: DialogInputField;
  value: string;
  setValue: (v: string) => void;
  accentColor: string;
  openSelectId: string | null;
  setOpenSelectId: (id: string | null) => void;
  selectRef: React.RefObject<HTMLDivElement | null>;
}) {
  const focusStyle = inputFocusStyle(accentColor);
  const inputType = (String(input.type || 'text')).toLowerCase();

  if (inputType === 'textarea') {
    return (
      <div>
        <label className="block text-[12px] font-medium text-white/50 mb-1.5">
          {input.label}
          {input.required && <span className="text-red-400 ml-0.5">*</span>}
        </label>
        <textarea
          className={`${inputBaseClass} resize-none`}
          placeholder={input.placeholder}
          value={value}
          onChange={(e) => setValue(e.target.value)}
          maxLength={input.maxLength}
          rows={3}
          {...focusStyle}
        />
      </div>
    );
  }

  if (inputType === 'date') {
    return (
      <div>
        <label className="block text-[12px] font-medium text-white/50 mb-1.5">
          {input.label}
          {input.required && <span className="text-red-400 ml-0.5">*</span>}
        </label>
        <input
          type="date"
          className={`${inputBaseClass} [&::-webkit-calendar-picker-indicator]:invert [&::-webkit-calendar-picker-indicator]:opacity-90`}
          value={value || ''}
          onChange={(e) => setValue(e.target.value)}
          {...focusStyle}
        />
      </div>
    );
  }

  if (inputType === 'select') {
    const options = input.options ?? [];
    const selected = options.find((o) => o.value === value);
    const isOpen = openSelectId === input.id;
    return (
      <div ref={input.id === openSelectId ? selectRef : undefined} className="relative">
        <label className="block text-[12px] font-medium text-white/50 mb-1.5">
          {input.label}
          {input.required && <span className="text-red-400 ml-0.5">*</span>}
        </label>
        <button
          type="button"
          className={`${inputBaseClass} text-left flex items-center justify-between`}
          onClick={() => setOpenSelectId(isOpen ? null : input.id)}
          style={{
            borderColor: isOpen ? accentColor : undefined,
            boxShadow: isOpen ? `0 0 0 1px ${accentColor}40` : undefined,
          }}
        >
          <span className={value ? 'text-white' : 'text-white/40'}>{selected ? selected.label : input.placeholder ?? 'Select...'}</span>
          <i className={`fa-solid fa-chevron-down text-white/50 text-xs transition-transform ${isOpen ? 'rotate-180' : ''}`} />
        </button>
        {isOpen && (
          <div
            className="absolute top-full left-0 right-0 mt-1 rounded-lg overflow-hidden bg-black/90 shadow-xl z-10 max-h-[200px] overflow-y-auto"
          >
            {options.map((opt) => (
              <button
                key={opt.value}
                type="button"
                className="w-full px-3 py-2.5 text-left text-[13px] text-white hover:bg-white/10 transition-colors flex items-center justify-between"
                style={opt.value === value ? { backgroundColor: `${accentColor}30` } : undefined}
                onClick={() => {
                  setValue(opt.value);
                  setOpenSelectId(null);
                }}
              >
                {opt.label}
                {opt.value === value && <i className="fa-solid fa-check text-xs" style={{ color: accentColor }} />}
              </button>
            ))}
          </div>
        )}
      </div>
    );
  }

  if (inputType === 'multiselect') {
    const options = input.options ?? [];
    let selectedValues: string[] = [];
    try {
      selectedValues = value ? JSON.parse(value) : [];
    } catch {
      selectedValues = [];
    }
    const availableOptions = options.filter((o) => !selectedValues.includes(o.value));
    const isOpen = openSelectId === input.id;
    const addOption = (optValue: string) => {
      if (selectedValues.includes(optValue)) return;
      setValue(JSON.stringify([...selectedValues, optValue]));
    };
    const removeOption = (optValue: string) => {
      setValue(JSON.stringify(selectedValues.filter((v) => v !== optValue)));
    };
    return (
      <div ref={input.id === openSelectId ? selectRef : undefined} className="relative">
        <label className="block text-[12px] font-medium text-white/50 mb-1.5">
          {input.label}
          {input.required && <span className="text-red-400 ml-0.5">*</span>}
        </label>
        <button
          type="button"
          className={`${inputBaseClass} text-left flex items-center flex-wrap gap-1.5 min-h-[42px] py-2`}
          onClick={() => setOpenSelectId(isOpen ? null : input.id)}
          style={{
            borderColor: isOpen ? accentColor : undefined,
            boxShadow: isOpen ? `0 0 0 1px ${accentColor}40` : undefined,
          }}
        >
          <span className="flex flex-wrap gap-1.5 flex-1 min-w-0">
            {selectedValues.length === 0 ? (
              <span className="text-white/40">{input.placeholder ?? 'Select...'}</span>
            ) : (
              selectedValues.map((v) => {
                const opt = options.find((o) => o.value === v);
                const label = opt ? opt.label : v;
                return (
                  <span
                    key={v}
                    className="inline-flex items-center gap-1 pl-2 pr-1 py-0.5 rounded text-[12px] text-white shrink-0"
                    style={{ backgroundColor: 'rgba(0,0,0,0.7)' }}
                  >
                    {label}
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        removeOption(v);
                      }}
                      className="rounded p-0.5 hover:bg-white/20 transition-colors"
                      aria-label="Remove"
                    >
                      <i className="fa-solid fa-times text-[10px] text-white/80" />
                    </button>
                  </span>
                );
              })
            )}
          </span>
          <i className={`fa-solid fa-chevron-down text-white/50 text-xs transition-transform flex-shrink-0 ${isOpen ? 'rotate-180' : ''}`} />
        </button>
        {isOpen && (
          <div
            className="absolute top-full left-0 right-0 mt-1 rounded-lg overflow-hidden bg-black/90 shadow-xl z-10 max-h-[200px] overflow-y-auto"
          >
            {availableOptions.length === 0 ? (
              <div className="px-3 py-2.5 text-[13px] text-white/50">Aucune option disponible</div>
            ) : (
              availableOptions.map((opt) => (
                <button
                  key={opt.value}
                  type="button"
                  className="w-full px-3 py-2.5 text-left text-[13px] text-white hover:bg-white/10 transition-colors"
                  onClick={() => addOption(opt.value)}
                >
                  {opt.label}
                </button>
              ))
            )}
          </div>
        )}
      </div>
    );
  }

  if (inputType === 'checkbox') {
    const checked = value === 'true';
    return (
      <div>
        <label className="block text-[12px] font-medium text-white/50 mb-1.5">
          {input.label}
          {input.required && <span className="text-red-400 ml-0.5">*</span>}
        </label>
        <label className="flex items-center gap-3 cursor-pointer justify-start w-full">
          <div
            role="button"
            tabIndex={0}
            onClick={() => setValue(checked ? 'false' : 'true')}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                setValue(checked ? 'false' : 'true');
              }
            }}
            className="w-4 h-4 rounded border flex items-center justify-center transition-all duration-150 flex-shrink-0"
            style={
              checked
                ? { backgroundColor: accentColor, borderColor: accentColor }
                : { borderColor: 'rgba(255,255,255,0.3)', backgroundColor: 'transparent' }
            }
          >
            {checked && <i className="fa-solid fa-check text-[8px] text-white" />}
          </div>
          <span className="text-[13px] text-white">{input.checkboxLabel ?? 'Yes'}</span>
        </label>
      </div>
    );
  }

  return (
    <div>
      <label className="block text-[12px] font-medium text-white/50 mb-1.5">
        {input.label}
        {input.required && <span className="text-red-400 ml-0.5">*</span>}
      </label>
      <input
        type={inputType === 'number' ? 'number' : inputType === 'password' ? 'password' : 'text'}
        className={inputBaseClass}
        placeholder={input.placeholder}
        value={value}
        onChange={(e) => setValue(e.target.value)}
        maxLength={input.maxLength}
        min={input.min}
        max={input.max}
        {...focusStyle}
      />
    </div>
  );
}

export function Dialog() {
  const { activeDialog, inputValues, setInputValue, submitDialog } = useDialogStore();
  const globalAccent = useConfigStore((s) => s.config.accentColor);
  const accentColor = activeDialog?.color || globalAccent;
  const [openSelectId, setOpenSelectId] = useState<string | null>(null);
  const selectRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!openSelectId) return;
    const handle = (e: MouseEvent) => {
      if (selectRef.current && !selectRef.current.contains(e.target as Node)) setOpenSelectId(null);
    };
    document.addEventListener('mousedown', handle);
    return () => document.removeEventListener('mousedown', handle);
  }, [openSelectId]);

  useKeyboard({}, !!activeDialog);

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
          <div className="absolute inset-0" />

          <motion.div
            className="relative w-full max-w-[500px] rounded-xl overflow-visible"
            style={{
              backgroundColor: 'rgba(0, 0, 0, 0.80)',
            }}
            initial={{ opacity: 0, scale: 0.9, y: 30 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 30 }}
            transition={{ type: 'spring', stiffness: 400, damping: 30 }}
          >
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
                  <DialogInputField
                    key={input.id}
                    input={input}
                    value={inputValues[input.id] ?? ''}
                    setValue={(v) => setInputValue(input.id, v)}
                    accentColor={accentColor}
                    openSelectId={openSelectId}
                    setOpenSelectId={setOpenSelectId}
                    selectRef={selectRef}
                  />
                ))}
              </div>
            )}

            <div className="px-6 py-4 flex items-center justify-end gap-2 border-t border-white/[0.06] overflow-x-hidden">
              {(activeDialog.buttons ?? [
                { label: 'Cancel', variant: 'secondary' as const, action: 'cancel' },
                { label: 'Confirm', variant: 'primary' as const, action: 'confirm' },
              ])
                .slice(0, 4)
                .map((btn) => {
                const isPrimary = btn.variant === 'primary';
                const isDanger = btn.variant === 'danger';
                  const hasCustomBg = !!btn.backgroundColor;

                return (
                  <button
                    key={btn.action}
                    onClick={() => submitDialog(btn.action)}
                    className="btn-shine inline-flex items-center justify-center px-4 h-[34px] rounded-lg text-[13px] font-medium transition-all duration-200 max-w-[110px]"
                    style={
                      hasCustomBg
                        ? {
                            backgroundColor: btn.backgroundColor,
                            color: '#ffffff',
                          }
                        : isPrimary
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
                      if (hasCustomBg) {
                        e.currentTarget.style.filter = 'brightness(1.12)';
                      } else if (isPrimary) {
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
                      if (hasCustomBg) {
                        e.currentTarget.style.filter = 'brightness(1)';
                      } else if (isPrimary) {
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
                    {btn.icon && <i className={`fa-solid fa-${btn.icon} mr-1.5 text-xs`} />}
                    <span
                      className="whitespace-normal text-center leading-snug"
                      style={{
                        display: '-webkit-box',
                        WebkitLineClamp: 2,
                        WebkitBoxOrient: 'vertical',
                        overflow: 'hidden',
                      }}
                    >
                      {btn.label}
                    </span>
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

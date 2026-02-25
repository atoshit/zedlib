import { useState } from 'react';
import { sendReactMessage } from '@/nui';

const presets = [
  {
    label: 'Register + Open Menu',
    messages: [
      {
        action: 'zedlib:registerMenu',
        data: {
          id: 'nui_test',
          title: 'NUI Test Menu',
          items: [
            { id: 'b1', type: 'button', label: 'Test Button', onSelect: 'test:btn' },
            { id: 'c1', type: 'checkbox', label: 'Test Check', checked: false, onChange: 'test:chk' },
          ],
        },
      },
      { action: 'zedlib:openMenu', data: { id: 'nui_test' } },
    ],
  },
  {
    label: 'Send Notification',
    messages: [
      {
        action: 'zedlib:notify',
        data: {
          type: 'info',
          title: 'NUI Notification',
          message: 'Sent via NUI simulator',
        },
      },
    ],
  },
  {
    label: 'Open Dialog',
    messages: [
      {
        action: 'zedlib:openDialog',
        data: {
          id: 'nui_dialog',
          type: 'input',
          title: 'NUI Dialog Test',
          message: 'This dialog was opened via NUI message',
          inputs: [
            { id: 'test_input', type: 'text', label: 'Test Field', placeholder: 'Enter something...' },
          ],
          buttons: [
            { label: 'Cancel', variant: 'secondary', action: 'cancel' },
            { label: 'OK', variant: 'primary', action: 'ok' },
          ],
          closable: true,
        },
      },
    ],
  },
  {
    label: 'Close Menu',
    messages: [{ action: 'zedlib:closeMenu', data: {} }],
  },
];

export function NuiSimulator() {
  const [customJson, setCustomJson] = useState('{\n  "action": "zedlib:notify",\n  "data": {\n    "type": "success",\n    "title": "Custom",\n    "message": "Custom NUI message"\n  }\n}');
  const [error, setError] = useState('');

  const handleSendCustom = () => {
    try {
      const parsed = JSON.parse(customJson);
      if (parsed.action && parsed.data !== undefined) {
        sendReactMessage(parsed.action, parsed.data);
        setError('');
      } else {
        setError('JSON must have "action" and "data" fields');
      }
    } catch {
      setError('Invalid JSON');
    }
  };

  const handlePreset = (preset: typeof presets[number]) => {
    for (const msg of preset.messages) {
      sendReactMessage(msg.action, msg.data);
    }
  };

  return (
    <div className="space-y-3">
      <p className="text-[11px] text-zed-text-dim">
        Simule des SendNUIMessage depuis Lua.
      </p>

      <div className="space-y-1.5">
        <p className="text-[10px] font-medium text-zed-text-muted uppercase tracking-wider">Présets</p>
        {presets.map((preset) => (
          <button
            key={preset.label}
            onClick={() => handlePreset(preset)}
            className="w-full text-left bg-zed-elevated/50 hover:bg-zed-elevated border border-zed-border/30 rounded-lg px-3 py-2 text-[11px] text-zed-text-muted hover:text-zed-text transition-all"
          >
            {preset.label}
          </button>
        ))}
      </div>

      <div className="space-y-1.5">
        <p className="text-[10px] font-medium text-zed-text-muted uppercase tracking-wider">Message custom</p>
        <textarea
          value={customJson}
          onChange={(e) => setCustomJson(e.target.value)}
          className="w-full h-32 bg-zed-bg/80 border border-zed-border/50 rounded-lg px-3 py-2 text-[11px] text-zed-text font-mono placeholder-zed-text-dim focus:outline-none focus:border-zed-accent/50 focus:ring-1 focus:ring-zed-accent/20 transition-all resize-none"
          spellCheck={false}
        />
        {error && <p className="text-[10px] text-zed-error">{error}</p>}
        <button
          onClick={handleSendCustom}
          className="w-full bg-zed-accent/10 hover:bg-zed-accent/20 text-zed-accent border border-zed-accent/20 rounded-lg px-3 py-2 text-[12px] font-medium transition-all"
        >
          Envoyer
        </button>
      </div>
    </div>
  );
}

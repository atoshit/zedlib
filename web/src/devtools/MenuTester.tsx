import { useMenuStore } from '@/stores';
import type { MenuDefinition } from '@/types';

const demoMenu: MenuDefinition = {
  id: 'demo_main',
  title: 'Menu Principal',
  subtitle: 'ZedLib Demo',
  items: [
    {
      id: 'btn_1',
      type: 'button',
      label: 'Mon Action',
      description: 'Execute une action simple',
      icon: '🎯',
      onSelect: 'demo:action',
    },
    {
      id: 'btn_2',
      type: 'button',
      label: 'Autre Action',
      icon: '🔥',
      onSelect: 'demo:other',
    },
    { id: 'sep_1', type: 'separator' },
    {
      id: 'chk_1',
      type: 'checkbox',
      label: 'God Mode',
      description: 'Invincibilité du joueur',
      checked: false,
      onChange: 'demo:godmode',
    },
    {
      id: 'chk_2',
      type: 'checkbox',
      label: 'Mode Invisible',
      checked: true,
      onChange: 'demo:invisible',
    },
    { id: 'sep_2', type: 'separator' },
    {
      id: 'list_1',
      type: 'list',
      label: 'Météo',
      items: [
        { label: 'Clair', value: 'clear' },
        { label: 'Nuageux', value: 'cloudy' },
        { label: 'Pluie', value: 'rain' },
        { label: 'Orage', value: 'thunder' },
        { label: 'Neige', value: 'snow' },
      ],
      currentIndex: 0,
      onChange: 'demo:weather',
    },
    {
      id: 'slider_1',
      type: 'slider',
      label: 'Vitesse',
      min: 0,
      max: 200,
      step: 10,
      value: 80,
      onChange: 'demo:speed',
    },
    { id: 'sep_3', type: 'separator' },
    {
      id: 'sub_1',
      type: 'submenu',
      label: 'Véhicules',
      description: 'Gérer les véhicules',
      icon: '🚗',
      targetMenu: 'demo_vehicles',
    },
    {
      id: 'sub_2',
      type: 'submenu',
      label: 'Paramètres',
      icon: '⚙️',
      targetMenu: 'demo_settings',
    },
  ],
};

const vehicleSubMenu: MenuDefinition = {
  id: 'demo_vehicles',
  title: 'Véhicules',
  subtitle: 'Spawner un véhicule',
  items: [
    { id: 'v_1', type: 'button', label: 'Adder', icon: '🏎️', onSelect: 'demo:spawn_adder' },
    { id: 'v_2', type: 'button', label: 'Zentorno', icon: '🏎️', onSelect: 'demo:spawn_zentorno' },
    { id: 'v_3', type: 'button', label: 'Tempesta', icon: '🏎️', onSelect: 'demo:spawn_tempesta' },
    { id: 'sep', type: 'separator' },
    { id: 'v_4', type: 'button', label: 'Supprimer véhicule', icon: '🗑️', onSelect: 'demo:delete_vehicle' },
  ],
};

const settingsSubMenu: MenuDefinition = {
  id: 'demo_settings',
  title: 'Paramètres',
  items: [
    { id: 's_1', type: 'checkbox', label: 'Notifications', checked: true, onChange: 'demo:toggle_notif' },
    { id: 's_2', type: 'checkbox', label: 'Sons', checked: true, onChange: 'demo:toggle_sound' },
    {
      id: 's_3',
      type: 'list',
      label: 'Langue',
      items: [
        { label: 'Français', value: 'fr' },
        { label: 'English', value: 'en' },
        { label: 'Español', value: 'es' },
      ],
      currentIndex: 0,
      onChange: 'demo:lang',
    },
  ],
};

export function MenuTester() {
  const { registerMenu, openMenu, closeMenu, visible } = useMenuStore();

  const handleOpenDemo = () => {
    registerMenu(demoMenu);
    registerMenu(vehicleSubMenu);
    registerMenu(settingsSubMenu);
    openMenu('demo_main');
  };

  return (
    <div className="space-y-3">
      <p className="text-[11px] text-zed-text-dim">
        Ouvre un menu démo avec boutons, checkboxes, listes, sliders et sous-menus.
      </p>

      <div className="flex gap-2">
        <button
          onClick={handleOpenDemo}
          className="flex-1 bg-zed-accent/10 hover:bg-zed-accent/20 text-zed-accent border border-zed-accent/20 rounded-lg px-3 py-2 text-[12px] font-medium transition-all"
        >
          Ouvrir Menu Demo
        </button>
        <button
          onClick={closeMenu}
          disabled={!visible}
          className="flex-1 bg-zed-elevated hover:bg-zed-border/50 text-zed-text-muted border border-zed-border/40 rounded-lg px-3 py-2 text-[12px] font-medium transition-all disabled:opacity-30"
        >
          Fermer Menu
        </button>
      </div>

      <div className="bg-zed-bg/50 rounded-lg p-3 border border-zed-border/20">
        <p className="text-[10px] text-zed-text-dim font-mono">
          <span className="text-zed-accent">Navigation :</span> ↑↓ Naviguer · Enter Sélectionner · ←→ Listes/Sliders · Backspace Retour · Esc Fermer
        </p>
      </div>

      <div className="bg-zed-bg/50 rounded-lg p-3 border border-zed-border/20">
        <p className="text-[10px] text-zed-text-dim">
          <span className="text-zed-accent">État :</span>{' '}
          {visible ? (
            <span className="text-zed-success">Menu ouvert</span>
          ) : (
            <span className="text-zed-text-dim">Aucun menu</span>
          )}
        </p>
      </div>
    </div>
  );
}

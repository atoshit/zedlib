import { useDialogStore } from '@/stores';
import type { DialogData } from '@/types';

const confirmDialog: DialogData = {
  id: 'demo_confirm',
  type: 'confirm',
  title: 'Confirmer l\'action',
  message: 'Êtes-vous sûr de vouloir supprimer ce véhicule ? Cette action est irréversible.',
  buttons: [
    { label: 'Annuler', variant: 'secondary', action: 'cancel' },
    { label: 'Supprimer', variant: 'danger', action: 'delete' },
  ],
  closable: true,
};

const inputDialog: DialogData = {
  id: 'demo_input',
  type: 'input',
  title: 'Spawner un véhicule',
  message: 'Entrez le nom du modèle à spawner.',
  inputs: [
    {
      id: 'model',
      type: 'text',
      label: 'Modèle',
      placeholder: 'adder, zentorno...',
      required: true,
    },
    {
      id: 'color',
      type: 'text',
      label: 'Couleur (optionnel)',
      placeholder: '#FF0000',
    },
  ],
  buttons: [
    { label: 'Annuler', variant: 'secondary', action: 'cancel' },
    { label: 'Spawner', variant: 'primary', action: 'spawn' },
  ],
  closable: true,
};

const multiInputDialog: DialogData = {
  id: 'demo_multi',
  type: 'input',
  title: 'Créer un personnage',
  inputs: [
    { id: 'firstname', type: 'text', label: 'Prénom', placeholder: 'Jean', required: true },
    { id: 'lastname', type: 'text', label: 'Nom', placeholder: 'Dupont', required: true },
    { id: 'age', type: 'number', label: 'Âge', placeholder: '25', min: 18, max: 80 },
    { id: 'bio', type: 'textarea', label: 'Biographie', placeholder: 'Décrivez votre personnage...' },
  ],
  buttons: [
    { label: 'Annuler', variant: 'secondary', action: 'cancel' },
    { label: 'Créer', variant: 'primary', action: 'create' },
  ],
  closable: true,
};

export function DialogTester() {
  const { openDialog, activeDialog } = useDialogStore();

  return (
    <div className="space-y-3">
      <p className="text-[11px] text-zed-text-dim">
        Test des différents types de dialogs.
      </p>

      <button
        onClick={() => openDialog(confirmDialog)}
        className="w-full bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 rounded-lg px-3 py-2 text-[12px] font-medium transition-all"
      >
        Dialog Confirmation
      </button>

      <button
        onClick={() => openDialog(inputDialog)}
        className="w-full bg-zed-accent/10 hover:bg-zed-accent/20 text-zed-accent border border-zed-accent/20 rounded-lg px-3 py-2 text-[12px] font-medium transition-all"
      >
        Dialog avec Inputs
      </button>

      <button
        onClick={() => openDialog(multiInputDialog)}
        className="w-full bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 border border-emerald-500/20 rounded-lg px-3 py-2 text-[12px] font-medium transition-all"
      >
        Dialog Multi-Inputs
      </button>

      <div className="bg-zed-bg/50 rounded-lg p-3 border border-zed-border/20">
        <p className="text-[10px] text-zed-text-dim">
          <span className="text-zed-accent">État :</span>{' '}
          {activeDialog ? (
            <span className="text-zed-success">Dialog ouvert ({activeDialog.id})</span>
          ) : (
            <span className="text-zed-text-dim">Aucun dialog</span>
          )}
        </p>
      </div>
    </div>
  );
}

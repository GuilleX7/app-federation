import type {
  AppFederationBridge,
  AppFederationEntryMount,
} from '@guillex7/app-federation';

type Props = { locale: string };
type Actions = {
  selectProduct: (id: string) => void
};
type Events = {
  'cart:changed': { count: number };
};

export const mount: AppFederationEntryMount = ({
  container,
  bridge,
  bus,
}: {
  container?: HTMLElement;
  bridge?: AppFederationBridge<Props, Actions>;
  bus?: AppFederationBus<Events>;
}) => {
  if (!container || !bridge || !bus) {
    throw new Error('All required parameters (container, bridge, bus) must be provided');
  }

  // Remote application logic here

  return {
    unmount: () => {
      container.innerHTML = "";
    },
  };
};

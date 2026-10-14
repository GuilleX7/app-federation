import {
  createAppBridge,
  createBus,
  loadAppInstanceEntry,
} from '@guillex7/app-federation';

type Props = { locale: string };
type Actions = {
  selectProduct: (id: string) => void
};
type Events = {
  'cart:changed': { count: number };
};

const bridge = createAppBridge<Props, Actions>(
  { locale: 'es' },
  { selectProduct: (id) => console.info('Product:', id) },
);
const bus = createBus<Events>();

const container = document.createElement("div");

const entry = await loadAppInstanceEntry("https://example.com/remote.js");
const lifecycle = await entry.mount({ container, bridge });

// When all applications using the bus are unloaded:
bus.dispose();

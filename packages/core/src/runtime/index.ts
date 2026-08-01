declare global {
  interface Window {
    __APP_FEDERATION__: {
      factories: Record<string, RemoteEntryContainerFactory>;
      define: (factory: RemoteEntryContainerFactory) => void;
    };
    [key: string]: unknown;
  }
}

type RemoteEntryContainerFactory = () => RemoteEntryContainer;

type RemoteEntryContainer = {
  init: (sharedDeps: Record<string, unknown>) => void;
  get: <T>(module: string) => Promise<() => T>;
};

type AppMountingLifecycle = {
  mount: (options: { container: HTMLElement }) => AppUnmountingLifecycle;
};

type AppUnmountingLifecycle = {
  unmount: () => void;
};

function joinUrls(...urls: string[]): string {
  try {
    let finalUrl: string | URL = document.URL;
    for (const url of urls) {
      finalUrl = new URL(url, finalUrl);
    }
    return finalUrl.toString();
  } catch {
    return '';
  }
}

function loadScript(url: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = url;
    script.type = 'text/javascript';
    script.onload = () => {
      script.remove();
      resolve();
    };
    script.onerror = () => {
      script.remove();
      reject(new Error(`Failed to load script: ${url}`));
    };
    document.head.appendChild(script);
  });
}

class Defer<T> {
  private _promise: Promise<T>;

  public resolve!: (value: T | PromiseLike<T>) => void;
  public reject!: (reason?: unknown) => void;

  public get promise(): Promise<T> {
    return this._promise;
  }

  constructor() {
    this._promise = new Promise<T>((res, rej) => {
      this.resolve = res;
      this.reject = rej;
    });
  }
}

let currentFrontendAppLoading: Defer<void> | null = null;

function ensureGlobalLoader(): void {
  if (!window.__APP_FEDERATION__) {
    window.__APP_FEDERATION__ = {
      factories: {},
      define: () => {},
    };
  }
}

function loadRemoteEntry(url: string): Promise<void> {
  ensureGlobalLoader();

  if (window.__APP_FEDERATION__.factories[url]) {
    return Promise.resolve();
  }

  window.__APP_FEDERATION__.define = (factory: RemoteEntryContainerFactory) => {
    window.__APP_FEDERATION__.factories[url] = factory;
  };

  return loadScript(url);
}

async function loadFrontendApp({
  container,
  url,
  name,
}: {
  container: HTMLElement;
  url: string;
  name: string;
}): Promise<AppUnmountingLifecycle> {
  if (currentFrontendAppLoading) {
    await currentFrontendAppLoading.promise;
  }
  currentFrontendAppLoading = new Defer<void>();

  const remoteEntryUrl = joinUrls(url, 'remoteEntry.js');
  await loadRemoteEntry(remoteEntryUrl);

  const remoteEntryContainerFactory =
    window.__APP_FEDERATION__.factories[remoteEntryUrl];
  const remoteEntryContainer = remoteEntryContainerFactory();
  remoteEntryContainer.init({});
  const metaActions = await remoteEntryContainer.get<{ teardown: () => void }>(
    'app-federation/runtime-module',
  );
  const { teardown } = metaActions();
  const factory = await remoteEntryContainer.get<{
    default: AppMountingLifecycle;
  }>('.');
  const appLifecycle = factory().default;
  const appLifecycleReturn = appLifecycle.mount({ container });
  currentFrontendAppLoading?.resolve();

  return {
    unmount: () => {
      appLifecycleReturn.unmount();
      teardown();
    },
  };
}

export { loadFrontendApp };
export type { AppMountingLifecycle, AppUnmountingLifecycle };

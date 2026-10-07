import type {
  LoadRemoteEntryOptions,
  AppFederationAppFactory,
  LoadAppInstanceOptions,
  AppFederationAppInstance,
  LoadAppInstanceEntryOptions,
  AppFederationAppEntry,
} from "../types.js";
import {
  DEFAULT_APP_ENTRY_NAME,
  DEFAULT_GLOBAL_AMD_CONTAINER,
  createDeferred,
  type Deferred,
} from "../utils.js";

type AppFederationAmdContainer = {
  define: (appFactory: AppFederationAppFactory) => void;
  appFactoryByRemoteEntryUrl: Record<string, Promise<AppFederationAppFactory>>;
  appFactoryLoadQueue: Deferred<AppFederationAppFactory>[];
};

type ExtendedSelf = {
  [key: string]: AppFederationAmdContainer | undefined;
};

function prepareAndGetAmdContainer(
  globalAmdContainer: string,
): AppFederationAmdContainer {
  const extendedSelf = self as unknown as ExtendedSelf;
  if (!extendedSelf[globalAmdContainer]) {
    extendedSelf[globalAmdContainer] = {} as AppFederationAmdContainer;
  }

  const amdContainer = extendedSelf[globalAmdContainer]!;

  if (!amdContainer.appFactoryByRemoteEntryUrl) {
    amdContainer.appFactoryByRemoteEntryUrl = Object.create(null);
  }

  if (!amdContainer.appFactoryLoadQueue) {
    amdContainer.appFactoryLoadQueue = [];
  }

  if (!amdContainer.define) {
    amdContainer.define = (appFactory) => {
      const deferred = amdContainer.appFactoryLoadQueue.shift();

      if (!deferred) {
        throw new Error("No app factory is waiting to be loaded");
      }

      deferred.resolve(appFactory);
    };
  }

  return amdContainer;
}

function removeDeferredFromLoadQueue(
  amdContainer: AppFederationAmdContainer,
  deferred: Deferred<AppFederationAppFactory>,
): void {
  const deferredIndex = amdContainer.appFactoryLoadQueue.indexOf(deferred);
  if (deferredIndex !== -1) {
    amdContainer.appFactoryLoadQueue.splice(deferredIndex, 1);
  }
}

export async function loadRemoteEntry(
  remoteEntryUrl: string,
  {
    internal: { globalAmdContainer = DEFAULT_GLOBAL_AMD_CONTAINER } = {},
  }: LoadRemoteEntryOptions = {},
): Promise<AppFederationAppFactory> {
  const amdContainer = prepareAndGetAmdContainer(globalAmdContainer);

  const loadedAppFactory =
    amdContainer.appFactoryByRemoteEntryUrl[remoteEntryUrl];
  if (loadedAppFactory) {
    return loadedAppFactory;
  }

  const deferred = createDeferred<AppFederationAppFactory>();
  const previousLoad = amdContainer.appFactoryLoadQueue.at(-1);
  amdContainer.appFactoryLoadQueue.push(deferred);

  const loadPromise = (async () => {
    if (previousLoad) {
      await previousLoad.promise.catch(() => undefined);
    }

    const remoteEntryScript = document.createElement("script");
    remoteEntryScript.src = remoteEntryUrl;
    remoteEntryScript.onerror = () => {
      delete amdContainer.appFactoryByRemoteEntryUrl[remoteEntryUrl];
      removeDeferredFromLoadQueue(amdContainer, deferred);
      deferred.reject(new Error("Failed to load remote entry"));
    };
    document.body.appendChild(remoteEntryScript);

    try {
      const appFactory = await deferred.promise;
      return appFactory;
    } finally {
      remoteEntryScript.remove();
    }
  })();

  amdContainer.appFactoryByRemoteEntryUrl[remoteEntryUrl] = loadPromise;
  return loadPromise;
}

export function computePublicPath(remoteEntryUrl: string): string {
  return new URL(".", new URL(remoteEntryUrl, document.baseURI)).href;
}

export async function loadAppInstance(
  remoteEntryUrl: string,
  options?: LoadAppInstanceOptions,
): Promise<AppFederationAppInstance> {
  const publicPath = computePublicPath(remoteEntryUrl);
  const appFactory = await loadRemoteEntry(remoteEntryUrl, options);
  const appInstance = await appFactory();
  appInstance.setPublicPath(publicPath);

  return appInstance;
}

export async function loadAppInstanceEntry(
  remoteEntryUrl: string,
  options?: LoadAppInstanceEntryOptions,
): Promise<AppFederationAppEntry> {
  const appInstance = await loadAppInstance(remoteEntryUrl, options);
  const appEntry = await appInstance.loadEntry(
    options?.entry || DEFAULT_APP_ENTRY_NAME,
  );
  return appEntry;
}

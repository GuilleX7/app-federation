import type {
  AppFederationAmdContainer,
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
} from "../utils.js";

function prepareAndGetAmdContainer(
  globalAmdContainer: string,
): AppFederationAmdContainer {
  const extendedSelf = self as unknown as {
    [key: string]: AppFederationAmdContainer;
  };

  if (!extendedSelf[globalAmdContainer]) {
    extendedSelf[globalAmdContainer] = {
      define: () => {
        // This will be overridden by the runtime module
      },
      appFactoryByRemoteEntryUrl: Object.create(null),
    };
  }

  if (!extendedSelf[globalAmdContainer].appFactoryByRemoteEntryUrl) {
    extendedSelf[globalAmdContainer].appFactoryByRemoteEntryUrl =
      Object.create(null);
  }

  return extendedSelf[globalAmdContainer];
}

export async function loadRemoteEntry(
  remoteEntryUrl: string,
  {
    internal: { globalAmdContainer = DEFAULT_GLOBAL_AMD_CONTAINER } = {},
  }: LoadRemoteEntryOptions = {},
): Promise<AppFederationAppFactory> {
  const amdContainer = prepareAndGetAmdContainer(globalAmdContainer);

  if (!amdContainer.appFactoryByRemoteEntryUrl[remoteEntryUrl]) {
    const remoteEntryScript = document.createElement("script");
    remoteEntryScript.src = remoteEntryUrl;
    document.body.appendChild(remoteEntryScript);

    const loadPromise = new Promise<AppFederationAppFactory>(
      (resolve, reject) => {
        remoteEntryScript.onerror = () => {
          delete amdContainer.appFactoryByRemoteEntryUrl[remoteEntryUrl];
          reject(new Error("Failed to load remote entry"));
        };

        amdContainer.define = (
          runtimeModuleFactory: AppFederationAppFactory,
        ) => {
          resolve(runtimeModuleFactory);
        };
      },
    ).finally(() => {
      remoteEntryScript.remove();
    });

    amdContainer.appFactoryByRemoteEntryUrl[remoteEntryUrl] = loadPromise;
  }

  return amdContainer.appFactoryByRemoteEntryUrl[remoteEntryUrl];
}

export async function loadAppInstance(
  remoteEntryUrl: string,
  options?: LoadAppInstanceOptions,
): Promise<AppFederationAppInstance> {
  const appFactory = await loadRemoteEntry(remoteEntryUrl, options);
  return appFactory();
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

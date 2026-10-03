import { createDeferred, type Deferred } from "./utils.ts";

declare global {
  interface Window {
    parentLoader?: ParentLoader;
  }
}

type RuntimeModuleFactory = () => Promise<RuntimeModuleInstance>;

type ParentLoader = {
  define: (runtimeModuleFactory: RuntimeModuleFactory) => void;
  loadedRuntimeFactories: Map<string, Promise<RuntimeModuleFactory>>;
  runtimeFactoryLoadQueue: Deferred<RuntimeModuleFactory>[];
};

type RuntimeModuleInstance = {
  getPublicPath: () => string;
  setPublicPath: (publicPath: string) => void;
  loadEntry: (entryName: string) => Promise<RuntimeModuleEntry>;
};

type RuntimeModuleEntry = {
  mount: (element: HTMLElement) => Promise<RuntimeModuleLifecycle>;
};

type RuntimeModuleLifecycle = {
  unmount: () => void;
};

document.body.innerHTML = `
    <h1>Parent</h1>
    <p>Microfrontend will be loaded here</p>
  `;

const mountButton = document.createElement("button");
mountButton.innerText = "Load microfrontend";
mountButton.addEventListener("click", async () => {
  const lifecycle = await loadMicrofrontend("http://localhost:8081/remote.js");

  const unmountButton = document.createElement("button");
  unmountButton.innerText = "Unmount microfrontend";
  unmountButton.addEventListener("click", async () => {
    lifecycle.unmount();
    unmountButton.remove();
  });
  document.body.appendChild(unmountButton);
});

function initializeParentLoader(): ParentLoader {
  if (!window.parentLoader) {
    window.parentLoader = {} as ParentLoader;
  }
  const parentLoader = window.parentLoader;

  if (!parentLoader.loadedRuntimeFactories) {
    parentLoader.loadedRuntimeFactories = new Map();
  }

  if (!parentLoader.runtimeFactoryLoadQueue) {
    parentLoader.runtimeFactoryLoadQueue = [];
  }

  if (!parentLoader.define) {
    parentLoader.define = (runtimeModuleFactory) => {
      const deferred = parentLoader.runtimeFactoryLoadQueue.shift();

      if (!deferred) {
        throw new Error("No runtime factory is waiting to be loaded");
      }

      deferred.resolve(runtimeModuleFactory);
    };
  }

  return parentLoader;
}

async function loadFactory(url: string): Promise<RuntimeModuleFactory> {
  const parentLoader = initializeParentLoader();
  const loadedRuntimeFactories = parentLoader.loadedRuntimeFactories!;
  const runtimeFactoryLoadQueue = parentLoader.runtimeFactoryLoadQueue!;

  const loadedRuntimeFactory = loadedRuntimeFactories.get(url);
  if (loadedRuntimeFactory) {
    return loadedRuntimeFactory;
  }

  const deferred = createDeferred<RuntimeModuleFactory>();
  const previousLoad = runtimeFactoryLoadQueue.at(-1);
  runtimeFactoryLoadQueue.push(deferred);

  const loadPromise = (async () => {
    if (previousLoad) {
      await previousLoad.promise.catch(() => undefined);
    }

    const remoteEntryScript = document.createElement("script");
    remoteEntryScript.src = url;
    remoteEntryScript.onerror = () => {
      loadedRuntimeFactories.delete(url);
      const deferredIndex = runtimeFactoryLoadQueue.indexOf(deferred);
      if (deferredIndex !== -1) {
        runtimeFactoryLoadQueue.splice(deferredIndex, 1);
      }
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

  loadedRuntimeFactories.set(url, loadPromise);
  return loadPromise;
}

async function loadMicrofrontend(
  url: string,
  entryName?: string,
): Promise<RuntimeModuleLifecycle> {
  const runtimeModuleFactory = await loadFactory(url);
  const runtimeModuleInstance = await runtimeModuleFactory();
  const publicPath = computePublicPath(url);
  runtimeModuleInstance.setPublicPath(publicPath);

  const runtimeModuleEntry = await runtimeModuleInstance.loadEntry(
    entryName ?? "default",
  );

  const container = document.createElement("div");
  container.style.border = "1px solid #000";
  container.style.minHeight = "100px";
  const runtimeModuleLifecycle = runtimeModuleEntry.mount(container);
  document.body.appendChild(container);

  return runtimeModuleLifecycle;
}

export function computePublicPath(remoteEntryUrl: string): string {
  return new URL(".", new URL(remoteEntryUrl, document.baseURI)).href;
}

document.body.appendChild(mountButton);

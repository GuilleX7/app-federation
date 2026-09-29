declare global {
  interface Window {
    parentLoader: {
      define: (runtimeModuleFactory: RuntimeModuleFactory) => void;
    };
  }
}

type RuntimeModuleFactory = () => Promise<RuntimeModuleInstance>;

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

const button = document.createElement("button");
button.innerText = "Load microfrontend";
button.addEventListener("click", async () => {
  const lifecycle = await loadMicrofrontend("http://localhost:8081/remote.js");

  const unmountButton = document.createElement("button");
  unmountButton.innerText = "Unmount microfrontend";
  unmountButton.addEventListener("click", async () => {
    lifecycle.unmount();
    unmountButton.remove();
  });
  document.body.appendChild(unmountButton);
});

const loadedRuntimeFactories = new Map<string, RuntimeModuleFactory>();

async function loadMicrofrontend(
  url: string,
  entryName?: string,
): Promise<RuntimeModuleLifecycle> {
  if (!loadedRuntimeFactories.has(url)) {
    const microfrontendScript = document.createElement("script");
    microfrontendScript.src = url;
    document.body.appendChild(microfrontendScript);

    await new Promise((resolve) => {
      window.parentLoader = {
        define: (runtimeModuleFactory: RuntimeModuleFactory) => {
          microfrontendScript.remove();
          loadedRuntimeFactories.set(url, runtimeModuleFactory);
          resolve(runtimeModuleFactory);
        },
      };
    });
  }

  const container = document.createElement("div");
  container.style.border = "1px solid #000";
  container.style.minHeight = "100px";

  const runtimeModuleFactory = loadedRuntimeFactories.get(url);
  if (!runtimeModuleFactory) {
    throw new Error(`Failed to load runtime module from URL: ${url}`);
  }

  const runtimeModuleInstance = await runtimeModuleFactory();
  const runtimeModuleEntry = await runtimeModuleInstance.loadEntry(
    entryName ?? "default",
  );
  const runtimeModuleLifecycle = runtimeModuleEntry.mount(container);
  document.body.appendChild(container);

  return runtimeModuleLifecycle;
}

document.body.appendChild(button);

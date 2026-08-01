declare global {
  interface Window {
    parentLoader: (runtimeModuleInstance: RuntimeModuleInstance) => void;
  }
}

type RuntimeModuleInstance = {
  mount: (element: HTMLElement) => void;
};

document.body.innerHTML = `
    <h1>Parent</h1>
    <p>Microfrontend will be loaded here</p>
  `;

const button = document.createElement("button");
button.innerText = "Load microfrontend";
button.addEventListener("click", () => {
  loadMicrofrontend("http://localhost:8081/main.js");
});

const loadedRuntimeModules = new Map<string, RuntimeModuleInstance>();

async function loadMicrofrontend(url: string): Promise<void> {
  if (!loadedRuntimeModules.has(url)) {
    const microfrontendScript = document.createElement("script");
    microfrontendScript.src = url;
    document.body.appendChild(microfrontendScript);

    await new Promise((resolve) => {
      window.parentLoader = (runtimeModuleInstance: RuntimeModuleInstance) => {
        loadedRuntimeModules.set(url, runtimeModuleInstance);
        resolve(runtimeModuleInstance);
      };
    });
  }

  const container = document.createElement("div");
  container.style.border = "1px solid #000";
  container.style.minHeight = "100px";
  document.body.appendChild(container);

  const runtimeModuleInstance = loadedRuntimeModules.get(url);
  if (runtimeModuleInstance) {
    runtimeModuleInstance.mount(container);
  }
}

document.body.appendChild(button);

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
  const microfrontendHost = "http://localhost:8081";
  const microfrontendScript = document.createElement("script");
  microfrontendScript.src = `${microfrontendHost}/main.js`;
  document.body.appendChild(microfrontendScript);

  window.parentLoader = (runtimeModuleInstance: RuntimeModuleInstance) => {
    const container = document.createElement("div");
    container.style.border = "1px solid #000";
    container.style.minHeight = "100px";
    document.body.appendChild(container);

    runtimeModuleInstance.mount(container);
  };
});

document.body.appendChild(button);

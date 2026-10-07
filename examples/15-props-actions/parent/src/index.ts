import {
  createAppBridge,
  loadAppInstanceEntry,
} from "../../library/dist/tools";
import "./global.css";

document.body.innerHTML = `
    <h1>Parent</h1>
    <p>Microfrontend will be loaded here</p>
  `;

const button = document.createElement("button");
button.innerText = "Load microfrontend";
button.addEventListener("click", async () => {
  const container = document.createElement("div");
  container.style.border = "1px solid #000";
  container.style.display = "block";
  container.style.margin = "16px 0px";

  const counterLabel = document.createElement("p");
  counterLabel.innerText = `Counter from parent: 0`;
  container.appendChild(counterLabel);

  const entry = await loadAppInstanceEntry<
    { counter: number },
    { incrementCounter: () => void; resetCounter: () => void }
  >("http://localhost:8081/remote.js");
  const bridge = createAppBridge(
    {
      counter: 0,
    },
    {
      incrementCounter: () => {
        bridge.props.set("counter", bridge.props.get("counter") + 1);
        counterLabel.innerText = `Counter from parent: ${bridge.props.get("counter")}`;
      },
      resetCounter: () => {
        bridge.props.set("counter", 0);
        counterLabel.innerText = `Counter from parent: 0`;
      },
    },
  );
  const lifecycle = await entry.mount({
    container,
    bridge,
  });
  document.body.appendChild(container);
  document.body.appendChild(counterLabel);

  const unmountButton = document.createElement("button");
  unmountButton.innerText = "Unmount microfrontend";
  unmountButton.addEventListener("click", () => {
    lifecycle.unmount();
    document.body.removeChild(container);
    document.body.removeChild(counterLabel);
    document.body.removeChild(unmountButton);
  });
  document.body.appendChild(unmountButton);
});

document.body.appendChild(button);

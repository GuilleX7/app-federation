import { createBus, loadAppInstanceEntry } from "../../library/dist/tools";
import {
  AppFederationBusEvent,
  type CommunicationEvents,
} from "../../contract";
import "./global.css";

document.body.innerHTML = `
  <h1>Parent</h1>
  <p>Send messages between the parent and the subchild.</p>
`;

const loadButton = document.createElement("button");
loadButton.innerText = "Load microfrontend";
loadButton.addEventListener("click", async () => {
  loadButton.disabled = true;

  const container = document.createElement("div");
  container.style.border = "1px solid #000";
  container.style.display = "block";
  container.style.margin = "16px 0px";

  const subchildMessage = document.createElement("p");
  subchildMessage.innerText = "Message from subchild: none";

  const bus = createBus<CommunicationEvents>();
  const unsubscribeFromSubchild = bus.subscribe(
    AppFederationBusEvent.SubchildMessage,
    (message) => {
      subchildMessage.innerText = `Message from subchild: ${message}`;
    },
  );

  const entry = await loadAppInstanceEntry("http://localhost:8081/remote.js");
  const lifecycle = await entry.mount({ container, bus });

  const parentMessageButton = document.createElement("button");
  parentMessageButton.innerText = "Send message to subchild";
  parentMessageButton.addEventListener("click", () => {
    bus.emit(AppFederationBusEvent.ParentMessage, "Hello from parent!");
  });

  document.body.append(container, parentMessageButton, subchildMessage);

  const unmountButton = document.createElement("button");
  unmountButton.innerText = "Unmount microfrontend";
  unmountButton.addEventListener("click", () => {
    lifecycle.unmount();
    unsubscribeFromSubchild();
    container.remove();
    parentMessageButton.remove();
    subchildMessage.remove();
    unmountButton.remove();
    loadButton.disabled = false;
  });
  document.body.appendChild(unmountButton);
});

document.body.appendChild(loadButton);

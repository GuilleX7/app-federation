import { createBus, loadAppInstanceEntry } from "../../library/dist/tools";
import {
  AppFederationBusEvent,
  type CommunicationEvents,
} from "../../contract";

const bus = createBus<CommunicationEvents>();
const parentMessageButton = document.createElement("button");
parentMessageButton.innerText = "Send message to subchild";
parentMessageButton.addEventListener("click", () => {
  bus.emit(AppFederationBusEvent.ParentMessage, "Hello from parent!");
});
document.body.appendChild(parentMessageButton);

loadAppInstanceEntry("remote.js")
  .then(async (entry) => {
    await entry.mount({ container: document.body, bus });
  })
  .catch((error: unknown) => {
    console.error("Failed to load the standalone microfrontend.", error);
  });

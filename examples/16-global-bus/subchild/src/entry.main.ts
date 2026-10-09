import type {
  AppFederationBus,
  AppFederationEntryLifecycle,
} from "../../library/dist/tools";
import {
  AppFederationBusEvent,
  type CommunicationEvents,
} from "../../contract";
import {
  createStyledContainer,
  tearDownStyleScoping,
} from "../../library/dist/runtime";
import "./global.css";

export function mount({
  container,
  bus,
}: {
  container?: HTMLElement;
  bus?: AppFederationBus<CommunicationEvents>;
}): AppFederationEntryLifecycle {
  if (!container || !bus) {
    throw new Error("Container and bus are required");
  }

  const innerContainer = createStyledContainer(container);
  innerContainer.className = "myContainer";
  innerContainer.innerHTML = `
    <h2>Subchild</h2>
    <p>Message from parent: none</p>
  `;

  const parentMessage = innerContainer.querySelector("p");
  if (!parentMessage) {
    throw new Error("Subchild message element was not created");
  }

  const unsubscribeFromParent = bus.subscribe(
    AppFederationBusEvent.ParentMessage,
    (message) => {
      parentMessage.innerText = `Message from parent: ${message}`;
    },
  );

  const subchildMessageButton = document.createElement("button");
  subchildMessageButton.innerText = "Send message to parent";
  subchildMessageButton.addEventListener("click", () => {
    bus.emit(AppFederationBusEvent.SubchildMessage, "Hello from subchild!");
  });
  innerContainer.appendChild(subchildMessageButton);

  return {
    unmount: () => {
      unsubscribeFromParent();
      tearDownStyleScoping();
      container.innerHTML = "";
    },
  };
}

import type {
  AppFederationBus,
  AppFederationEntryLifecycle,
} from "../../library/dist/tools";
import { BusEvent, type BusEventPayload } from "../../contract";
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
  bus?: AppFederationBus<BusEventPayload>;
}): AppFederationEntryLifecycle {
  if (!container || !bus) {
    throw new Error("Container and bus are required");
  }

  const innerContainer = createStyledContainer(container);
  innerContainer.className = "myContainer";
  innerContainer.innerHTML = `
    <h2>Subchild</h2>
    <p>Last greeting from another app: none</p>
  `;

  const lastGreeting = innerContainer.querySelector("p");
  if (!lastGreeting) {
    throw new Error("Subchild greeting element was not created");
  }

  const unsubscribeFromHello = bus.subscribe(BusEvent.Hello, (greeting) => {
    if (greeting.sender !== "subchild") {
      lastGreeting.innerText = `Last greeting from ${greeting.sender}`;
    }
  });

  const helloButton = document.createElement("button");
  helloButton.innerText = "Send hello from subchild";
  helloButton.addEventListener("click", () => {
    bus.emit(BusEvent.Hello, {
      sender: "subchild",
    });
  });
  innerContainer.appendChild(helloButton);

  return {
    unmount: () => {
      unsubscribeFromHello();
      tearDownStyleScoping();
      container.innerHTML = "";
    },
  };
}

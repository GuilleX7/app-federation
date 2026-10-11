import type {
  AppFederationBus,
  AppFederationEntryLifecycle,
} from "../../library/dist/tools";
import { loadAppInstanceEntry } from "../../library/dist/tools";
import { BusEvent, type BusEventPayload } from "../../contract";
import {
  createStyledContainer,
  tearDownStyleScoping,
} from "../../library/dist/runtime";
import "./global.css";

export async function mount({
  container,
  bus,
}: {
  container?: HTMLElement;
  bus?: AppFederationBus<BusEventPayload>;
}): Promise<AppFederationEntryLifecycle> {
  if (!container || !bus) {
    throw new Error("Container and bus are required");
  }

  const innerContainer = createStyledContainer(container);
  innerContainer.className = "myContainer";
  innerContainer.innerHTML = `
    <h1>Child</h1>
  `;

  const lastGreeting = document.createElement("p");
  lastGreeting.innerText = "Last greeting from another app: none";
  innerContainer.appendChild(lastGreeting);

  const unsubscribeFromHello = bus.subscribe(BusEvent.Hello, (greeting) => {
    if (greeting.sender !== "child") {
      lastGreeting.innerText = `Last greeting from ${greeting.sender}`;
    }
  });

  const helloButton = document.createElement("button");
  helloButton.innerText = "Send hello from child";
  helloButton.addEventListener("click", () => {
    bus.emit(BusEvent.Hello, {
      sender: "child",
    });
  });
  innerContainer.appendChild(helloButton);

  const subchildContainer = document.createElement("div");
  subchildContainer.style.border = "1px solid #000";
  subchildContainer.style.display = "block";
  subchildContainer.style.marginTop = "8px";
  innerContainer.appendChild(subchildContainer);

  const subchildEntry = await loadAppInstanceEntry(
    "http://localhost:8082/remote.js",
  );
  const subchildLifecycle = await subchildEntry.mount({
    container: subchildContainer,
    bus,
  });

  return {
    unmount: () => {
      subchildLifecycle.unmount();
      unsubscribeFromHello();
      tearDownStyleScoping();
      container.innerHTML = "";
    },
  };
}

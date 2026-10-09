import type {
  AppFederationBus,
  AppFederationEntryLifecycle,
} from "../../library/dist/tools";
import { loadAppInstanceEntry } from "../../library/dist/tools";
import type { CommunicationEvents } from "../../contract";
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
  bus?: AppFederationBus<CommunicationEvents>;
}): Promise<AppFederationEntryLifecycle> {
  if (!container || !bus) {
    throw new Error("Container and bus are required");
  }

  const innerContainer = createStyledContainer(container);
  innerContainer.className = "myContainer";
  innerContainer.innerHTML = `
    <h1>Child</h1>
    <p>The child passes the same bus to its subchild.</p>
  `;

  const subchildContainer = document.createElement("div");
  subchildContainer.style.border = "1px solid #000";
  subchildContainer.style.margin = "16px 0px";
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
      tearDownStyleScoping();
      container.innerHTML = "";
    },
  };
}

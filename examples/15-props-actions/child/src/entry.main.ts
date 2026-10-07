import type {
  AppFederationBridge,
  AppFederationEntryLifecycle,
  AppFederationEntryMount,
} from "../../library/dist/tools";
import {
  createStyledContainer,
  tearDownStyleScoping,
} from "../../library/dist/runtime";
import "./global.css";

export const mount: AppFederationEntryMount = ({
  container,
  bridge,
}: {
  container?: HTMLElement;
  bridge?: AppFederationBridge<
    { counter: number },
    { incrementCounter: () => void; resetCounter: () => void }
  >;
}): AppFederationEntryLifecycle => {
  if (!container || !bridge) {
    throw new Error("Container and bridge are required");
  }

  const innerContainer = createStyledContainer(container);
  innerContainer.className = "myContainer";
  innerContainer.innerHTML = `
    <h1>My first microfrontend</h1>
    <p>This is a simple microfrontend example.</p>
  `;

  const counterLabel = document.createElement("p");
  counterLabel.innerText = `Counter from child: ${bridge.props.get("counter")}`;
  innerContainer.appendChild(counterLabel);

  bridge.props.subscribe("counter", (value) => {
    counterLabel.innerText = `Counter from child: ${value}`;
  });

  const incrementButton = document.createElement("button");
  incrementButton.innerText = "Increment counter";
  incrementButton.addEventListener("click", () => {
    bridge.actions.incrementCounter();
  });
  innerContainer.appendChild(incrementButton);

  const resetButton = document.createElement("button");
  resetButton.innerText = "Reset counter";
  resetButton.addEventListener("click", () => {
    bridge.actions.resetCounter();
  });
  innerContainer.appendChild(resetButton);

  return {
    unmount: () => {
      tearDownStyleScoping();
      bridge.props.unsubscribeAll();
      container.innerHTML = "";
    },
  };
};

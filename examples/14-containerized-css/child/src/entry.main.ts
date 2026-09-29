import { add } from "examples-sample-lib";
import type {
  AppFederationEntryLifecycle,
  AppFederationEntryMount,
} from "../../library/dist/tools";
import {
  createStyledContainer,
  tearDownStyleScoping,
  getRegisteredModulesCss,
  getPublicPath,
} from "../../library/dist/runtime";
import "./global.css";

let counter = 0;

export const mount: AppFederationEntryMount = ({
  container,
}: {
  container?: HTMLElement | undefined;
}): AppFederationEntryLifecycle => {
  if (!container) {
    throw new Error("Container is required");
  }

  const innerContainer = createStyledContainer(container);
  innerContainer.className = "myContainer";
  innerContainer.innerHTML = `
    <h1>My first microfrontend</h1>
    <p>This is a simple microfrontend example.</p>
    <p>How many items has this instance been mounted before?: ${counter}</p>
    <p>How many registered CSS modules?: ${getRegisteredModulesCss().size}</p>
    <p>Public path: ${getPublicPath()}</p>
  `;

  counter = add(counter, 1);

  return {
    unmount: () => {
      tearDownStyleScoping();
      container.innerHTML = "";
    },
  };
};

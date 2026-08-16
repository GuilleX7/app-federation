import { add } from "examples-sample-lib";
import type {
  AppFederationEntryLifecycle,
  AppFederationEntryMount,
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

  container.innerHTML = `
  <div class="my-container">
    <h1>My first microfrontend</h1>
    <p>This is a simple microfrontend example.</p>
    <p>How many items has this instance been mounted before?: ${counter}</p>
  </div>
  `;

  counter = add(counter, 1);

  return {
    unmount: () => {
      container.innerHTML = "";
    },
  };
};

import { add } from "examples-sample-lib";
import type {
  AppFederationAppEgress,
  AppFederationAppMount,
} from "examples-11-library-plugin-library/runtime";

let counter = 0;

export const mount: AppFederationAppMount = ({
  container,
}: {
  container?: HTMLElement | undefined;
}): AppFederationAppEgress => {
  if (!container) {
    throw new Error("Container is required");
  }

  container.innerHTML = `
    <h1>My first microfrontend</h1>
    <p>This is a simple microfrontend example.</p>
    <p>Counters: ${counter}</p>
  `;

  counter = add(counter, 1);

  return {
    unmount: () => {
      container.innerHTML = "";
    },
  };
};

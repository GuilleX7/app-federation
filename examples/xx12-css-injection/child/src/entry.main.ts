import { add } from "examples-sample-lib";
import type {
  AppFederationAppLifecycle,
  AppFederationAppMount,
} from "examples-12-library-plugin-library/runtime";
import * as styles from "./entry.module.css";

let counter = 0;

export const mount: AppFederationAppMount = ({
  container,
}: {
  container?: HTMLElement | undefined;
}): AppFederationAppLifecycle => {
  if (!container) {
    throw new Error("Container is required");
  }

  container.innerHTML = `
  <div class="${styles.body}">  
    <h1>My first microfrontend</h1>
    <p>This is a simple microfrontend example.</p>
    <p>How many items has this instance been mounted before?: ${counter}</p>
  </div>
  `;

  console.log(styles.body, styles.default);

  counter = add(counter, 1);

  return {
    unmount: () => {
      container.innerHTML = "";
    },
  };
};

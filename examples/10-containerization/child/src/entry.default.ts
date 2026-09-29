import { add } from "examples-sample-lib";
import { getPublicPath } from "./index.remote.ts";

let counter = 0;

export async function mount(
  element: HTMLElement,
): Promise<{ unmount: () => void }> {
  element.innerHTML = `
    <h1>My first microfrontend</h1>
    <p>This is a simple microfrontend example.</p>
    <p>How many items has this instance been mounted before?: ${counter}</p>
    <p>Public path: ${getPublicPath()}</p>
  `;

  counter = add(counter, 1);

  return {
    unmount: () => {
      element.remove();
    },
  };
}

import { add } from "examples-sample-lib";

let counter = 0;

export async function mount(element: HTMLElement): Promise<void> {
  element.innerHTML = `
    <h1>My first microfrontend</h1>
    <p>This is a simple microfrontend example.</p>
    <p>Counters: ${counter}</p>
  `;

  counter = add(counter, 1);
}

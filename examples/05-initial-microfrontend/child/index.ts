export function mount(element: HTMLElement): void {
  element.innerHTML = `
    <h1>My first microfrontend</h1>
    <p>This is a simple microfrontend example.</p>
  `;
}

mount(document.body);

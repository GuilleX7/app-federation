import { loadAppInstanceEntry } from "../../library/dist/runtime";

document.body.innerHTML = `
    <h1>Parent</h1>
    <p>Microfrontend will be loaded here</p>
  `;

const button = document.createElement("button");
button.innerText = "Load microfrontend";
button.addEventListener("click", async () => {
  const container = document.createElement("div");
  container.style.border = "1px solid #000";
  container.style.minHeight = "100px";

  const entry = await loadAppInstanceEntry("http://localhost:8081/remote.js");
  const lifecycle = await entry.mount({ container });
  document.body.appendChild(container);

  const unmountButton = document.createElement("button");
  unmountButton.innerText = "Unmount microfrontend";
  unmountButton.addEventListener("click", () => {
    lifecycle.unmount();
    document.body.removeChild(container);
    document.body.removeChild(unmountButton);
  });
  document.body.appendChild(unmountButton);
});

document.body.appendChild(button);

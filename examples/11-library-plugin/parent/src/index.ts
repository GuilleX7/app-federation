import { loadAppInstance } from "examples-11-library-plugin-library/runtime";

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
  const instance = await loadAppInstance("http://localhost:8081/remote.js");
  const entry = await instance.loadEntry("app");
  entry.mount({ container });
  document.body.appendChild(container);
});

document.body.appendChild(button);

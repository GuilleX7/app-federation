document.body.innerHTML = `
    <h1>Parent</h1>
    <p>Microfrontend will be loaded here</p>
  `;

const button = document.createElement("button");
button.innerText = "Load microfrontend";
button.addEventListener("click", () => {
  const microfrontendHost = "http://localhost:8081";
  const microfrontendScript = document.createElement("script");
  microfrontendScript.src = `${microfrontendHost}/main.js`;
  document.body.appendChild(microfrontendScript);
});

document.body.appendChild(button);

import { loadAppInstanceEntry } from "@guillex7/app-federation";

const container = document.querySelector("#remote-container");
if (!(container instanceof HTMLElement)) {
  throw new Error("A container is needed");
}

const entry = await loadAppInstanceEntry(
  "https://example.com/remote.js",
);
const lifecycle = await entry.mount({ container });

// When application is no longer needed:
await lifecycle.unmount();

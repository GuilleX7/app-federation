import { loadAppInstanceEntry } from "@guillex7/app-federation";

loadAppInstanceEntry("remote.js").then((entry) => {
  entry.mount({ container: document.body });
});

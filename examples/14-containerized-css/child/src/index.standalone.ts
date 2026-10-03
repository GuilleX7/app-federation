import { loadAppInstanceEntry } from "../../library/dist/tools";

loadAppInstanceEntry("remote.js").then((entry) => {
  entry.mount({ container: document.body });
});

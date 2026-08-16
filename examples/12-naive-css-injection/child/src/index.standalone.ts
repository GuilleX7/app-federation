import { loadAppInstanceEntry } from "../../library/dist/runtime";

loadAppInstanceEntry("remote.js").then((entry) => {
  entry.mount({ container: document.body });
});

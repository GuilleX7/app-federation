import type { AppFederationEntryMount } from "@guillex7/app-federation";
import {
  createStyledContainer,
  tearDownStyleScoping,
} from "@guillex7/app-federation/runtime";
import "./global.css";

export const mount: AppFederationEntryMount = ({ container }) => {
  if (!container) {
    throw new Error("A container is needed");
  }

  const appContainer = createStyledContainer(container);
  const title = document.createElement("h1");
  title.textContent = "Hello world!";
  appContainer.appendChild(title);

  return {
    unmount: () => {
      tearDownStyleScoping();
      container.innerHTML = "";
    },
  };
};

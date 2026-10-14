import type { AppFederationEntryMount } from "@guillex7/app-federation";

export const mount: AppFederationEntryMount = ({ container }) => {
  if (!container) {
    throw new Error("Se necesita un contenedor");
  }

  container.textContent = "Aplicación remota";

  return {
    unmount: () => {
      container.innerHTML = "";
    },
  };
};

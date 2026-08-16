import path from "path";
import type { AppFederationPluginOptions } from "../../types.js";

export const BOOTSTRAP_FILENAME = "bootstrap.js";

export function getBootstrapCode(
  compilerContext: string,
  options: Required<Omit<AppFederationPluginOptions, "internal">>,
): string {
  const entryImports = Object.entries(options.entries)
    .map(
      ([entryName, entryPath]) =>
        `[${JSON.stringify(entryName)}]: () => import(${JSON.stringify(
          path.join(compilerContext, entryPath),
        )})`,
    )
    .join(",\n");

  const bootstrapCode = `
export function getPublicPath() {
  return __webpack_public_path__;
}

export function setPublicPath(publicPath) {
  __webpack_public_path__ = publicPath;
}

export async function loadEntry(entryName) {
  const entries = {
    ${entryImports}
  };
  if (!entries[entryName]) {
    throw new Error(\`Entry \${entryName} was not found in ${options.remoteEntryName} remote.\nAvailable entries: \${Object.keys(entries).join(", ")}\`);
  }
  const entry = await entries[entryName]();
  return {
    mount: (...args) => {
      if (args[0] && typeof args[0] === "object" && "container" in args[0]) {
        console.log("container", args[0].container);
      }
      entry.mount(...args);
    },
  };
}
`;

  return bootstrapCode;
}

import path from "path";
import type { AppFederationPluginOptions } from "../../types.js";

export const BOOTSTRAP_FILENAME = "bootstrap.js";

export function getBootstrapCode(
  compilerContext: string,
  options: Required<Omit<AppFederationPluginOptions, "internal">>,
): string {
  const instanceRuntimeRequestString = JSON.stringify(
    path.join(import.meta.dirname, "../../runtime/instance.js"),
  );
  const entryImports = Object.entries(options.entries)
    .map(
      ([entryName, entryPath]) =>
        `[${JSON.stringify(entryName)}]: () => import(${JSON.stringify(
          path.join(compilerContext, entryPath),
        )})`,
    )
    .join(",\n");

  const bootstrapCode = `
import { setRemoteEntryName, registerEntries } from ${instanceRuntimeRequestString};

setRemoteEntryName(${JSON.stringify(options.remoteEntryName)});
registerEntries({
  ${entryImports}
});

export { getPublicPath, setPublicPath, loadEntry } from ${instanceRuntimeRequestString};
`;

  return bootstrapCode;
}

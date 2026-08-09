import {
  type RspackPluginInstance,
  type Compiler,
  type EntryOptions,
  type EntryStaticNormalized,
  type EntryDescriptionNormalized,
  rspack,
} from "@rspack/core";
import {
  DEFAULT_REMOTE_ENTRY_NAME,
  DEFAULT_GLOBAL_AMD_CONTAINER,
  getRemoteEntryModuleName,
  type DeepRequired,
} from "../utils.js";
import path from "node:path";

export type AppFederationPluginOptions = {
  entries: Record<string, string>;
  remoteEntryName?: string;
  internal?: AppFederationPluginInternalOptions;
};

export type AppFederationPluginInternalOptions = {
  amdContainer?: string;
};

export class RspackAppFederationPlugin implements RspackPluginInstance {
  private options: DeepRequired<AppFederationPluginOptions>;

  constructor({
    entries,
    remoteEntryName = DEFAULT_REMOTE_ENTRY_NAME,
    internal: { amdContainer = DEFAULT_GLOBAL_AMD_CONTAINER } = {},
  }: AppFederationPluginOptions) {
    if (!entries || Object.keys(entries).length === 0) {
      throw new Error("At least one entry must be defined");
    }

    this.options = {
      entries,
      remoteEntryName,
      internal: {
        amdContainer: `self.${amdContainer}`,
      },
    };
  }

  private getRemoteEntryModule(compilerContext: string): {
    moduleName: string;
    code: string;
  } {
    const remoteEntryModuleName = getRemoteEntryModuleName(
      this.options.remoteEntryName,
    );

    const entryImports = Object.entries(this.options.entries)
      .map(
        ([entryName, entryPath]) =>
          `[${JSON.stringify(entryName)}]: () => import(${JSON.stringify(
            path.join(compilerContext, entryPath),
          )})`,
      )
      .join(",\n");

    const remoteEntryModuleCode = `
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
    throw new Error(\`Entry \${entryName} was not found in ${this.options.remoteEntryName} remote.\nAvailable entries: \${Object.keys(entries).join(", ")}\`);
  }
  return entries[entryName]();
}
`;

    return {
      moduleName: remoteEntryModuleName,
      code: remoteEntryModuleCode,
    };
  }

  apply(compiler: Compiler) {
    const { experiments } = compiler.webpack;

    const { moduleName: remoteEntryModuleName, code: remoteEntryModuleCode } =
      this.getRemoteEntryModule(compiler.context);

    const virtualModulesPlugin = new experiments.VirtualModulesPlugin({
      [remoteEntryModuleName]: remoteEntryModuleCode,
    });
    virtualModulesPlugin.apply(compiler);

    const entryOptions: EntryDescriptionNormalized = {
      import: [remoteEntryModuleName],
      library: {
        type: "amd",
        amdContainer: this.options.internal.amdContainer,
      },
    };

    if (typeof compiler.options.entry === "function") {
      const originalEntry = compiler.options.entry;
      compiler.options.entry = () =>
        originalEntry().then((configuration) => {
          configuration[this.options.remoteEntryName] = entryOptions;
          return configuration;
        });
    } else {
      compiler.options.entry[this.options.remoteEntryName] = entryOptions;
    }
  }
}

import {
  type RspackPluginInstance,
  type Compiler as RspackCompiler,
  type EntryDescriptionNormalized,
} from "@rspack/core";
import {
  DEFAULT_REMOTE_ENTRY_NAME,
  DEFAULT_GLOBAL_AMD_CONTAINER,
  type DeepRequired,
} from "../utils.js";
import type { AppFederationPluginOptions } from "../types.js";
import { getRemoteEntryModule } from "./remoteEntry.js";

class RspackAppFederationPlugin implements RspackPluginInstance {
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

  apply(compiler: RspackCompiler) {
    const { moduleName: remoteEntryModuleName, code: remoteEntryModuleCode } =
      getRemoteEntryModule(compiler.context, this.options);

    const virtualModulesPlugin =
      new compiler.rspack.experiments.VirtualModulesPlugin({
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
          return configuration as any;
        });
    } else {
      compiler.options.entry[this.options.remoteEntryName] = entryOptions;
    }
  }
}

const RspackPlugin = RspackAppFederationPlugin;

export { RspackPlugin as AppFederationRspackPlugin };

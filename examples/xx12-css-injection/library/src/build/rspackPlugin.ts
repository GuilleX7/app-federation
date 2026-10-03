import {
  type RspackPluginInstance,
  type Compiler as RspackCompiler,
  type EntryDescriptionNormalized,
  type RuleSetCondition,
  NormalModule,
} from "@rspack/core";
import {
  DEFAULT_REMOTE_ENTRY_NAME,
  DEFAULT_GLOBAL_AMD_CONTAINER,
  type DeepRequired,
  getRemoteEntryPrefix,
} from "../utils.js";
import type { AppFederationPluginOptions } from "../types.js";
import { getRemoteEntryModule } from "./remoteEntry.js";
import path from "node:path";
import { mkdirSync, writeFileSync } from "node:fs";

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
      layer: "remote",
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

    const cssRules: RuleSetCondition[] = [];
    compiler.options.module.rules.forEach((rule) => {
      if (!rule || typeof rule !== "object") {
        return;
      }

      if (rule?.type?.startsWith("css")) {
        compiler.options.module.rules.push({
          ...rule,
          parser: {
            ...rule.parser,
            exportType: "css-style-sheet",
            namedExports: false,
          },
          issuerLayer: "remote",
        });

        cssRules.push(rule.test as RuleSetCondition);
      }
    });

    compiler.hooks.compilation.tap(
      "AppFederationPlugin",
      (compilation, { normalModuleFactory }) => {
        compilation.hooks.buildModule.tap("AppFederationPlugin", (module) => {
          if (module instanceof NormalModule) {
            console.log("checking module", module.rawRequest);
          }
        });
        normalModuleFactory.hooks.afterResolve.tap(
          "AppFederationPlugin",
          (resolveData) => {
            console.log("afterResolve", resolveData);
            // const isCssRequest = cssRules.some((rule) => {
            //   if (typeof rule === "string") {
            //     return resolveData.request?.includes(rule);
            //   }
            //   if (rule instanceof RegExp) {
            //     return rule.test(resolveData.request || "");
            //   }
            //   return false;
            // });

            // if (
            //   !isCssRequest ||
            //   resolveData.contextInfo.issuerLayer !== "remote"
            // ) {
            //   return;
            // }

            // const originalRequest = resolveData.request;
            // const originalPath = path.resolve(
            //   resolveData.context,
            //   originalRequest,
            // );
            // const replacedRequest = path.resolve(
            //   compiler.context,
            //   "node_modules",
            //   ".app_fed",
            //   `${originalRequest}.js`,
            // );
            // resolveData.request = replacedRequest;

            // mkdirSync(path.dirname(replacedRequest), { recursive: true });
            // writeFileSync(
            //   replacedRequest,
            //   `export * from ${JSON.stringify(originalPath + "?original")};
            //   export default ${JSON.stringify(originalPath + "?original")};`,
            // );
          },
        );
      },
    );
    // const normalReplacePlugin =
    //   new compiler.rspack.NormalModuleReplacementPlugin(
    //     /\.css$/,
    //     (resource) => {
    //       if (resource.contextInfo.issuerLayer !== "remote") {
    //         console.log("Not remote", resource.contextInfo.issuerLayer);
    //         return;
    //       }

    //       const originalRequest = resource.request;
    //       const originalPath = path.resolve(resource.context, originalRequest);
    //       const replacedRequest = path.resolve(
    //         compiler.context,
    //         "node_modules",
    //         ".app_fed",
    //         `${originalRequest}.js`,
    //       );
    //       resource.request = replacedRequest;

    //       mkdirSync(path.dirname(replacedRequest), { recursive: true });
    //       writeFileSync(
    //         replacedRequest,
    //         `export * from ${JSON.stringify(originalPath + "?original")};`,
    //       );
    //     },
    //   );
    // normalReplacePlugin.apply(compiler);
  }
}

const RspackPlugin = RspackAppFederationPlugin;

export { RspackPlugin as AppFederationRspackPlugin };

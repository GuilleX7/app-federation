import {
  type RspackPluginInstance,
  type Compiler as RspackCompiler,
  type EntryDescriptionNormalized,
  type RuleSetRule,
  type RuleSetRules,
} from "@rspack/core";
import {
  DEFAULT_REMOTE_ENTRY_NAME,
  DEFAULT_GLOBAL_AMD_CONTAINER,
  type DeepRequired,
  DEFAULT_APP_ENTRY_NAME,
} from "../../utils.js";
import type { AppFederationPluginOptions } from "../../types.js";
import { TempFS } from "../internal/tempFs.js";
import path from "path";
import {
  BOOTSTRAP_FILENAME,
  getBootstrapCode,
} from "../generators/bootstrapModule.js";
import { matchesRuleSetRule } from "../internal/ruleSet.js";
import { logger } from "@rsbuild/core";
import { CssModuleGenerator } from "../generators/cssModule.js";

type AppFederationNormalizedPluginOptions = DeepRequired<
  AppFederationPluginOptions & {
    entries: Record<string, string>;
  }
>;

class RspackAppFederationPlugin implements RspackPluginInstance {
  private options: AppFederationNormalizedPluginOptions;

  constructor({
    entries,
    remoteEntryName = DEFAULT_REMOTE_ENTRY_NAME,
    internal: { amdContainer = DEFAULT_GLOBAL_AMD_CONTAINER } = {},
  }: AppFederationPluginOptions) {
    if (typeof entries === "string") {
      entries = { [DEFAULT_APP_ENTRY_NAME]: entries };
    } else if (Object.keys(entries).length === 0) {
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

  private applyBootstrapLogic(compiler: RspackCompiler, tempFs: TempFS): void {
    tempFs.write(
      BOOTSTRAP_FILENAME,
      getBootstrapCode(compiler.context, this.options),
    );

    const entryOptions: EntryDescriptionNormalized = {
      import: [tempFs.getPath(BOOTSTRAP_FILENAME)],
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

  private applyCssLogic(compiler: RspackCompiler, tempFs: TempFS): void {
    const cssModuleGenerator = new CssModuleGenerator();
    const ruleSetRules: RuleSetRules = compiler.options.module?.rules || [];
    const cssSetRules: RuleSetRule[] = [];

    ruleSetRules.forEach((rule) => {
      if (
        rule &&
        typeof rule === "object" &&
        ["css", "css/auto", "css/module", "css/global"].includes(
          rule.type || "",
        )
      ) {
        cssSetRules.push(rule);
        if (!rule.parser) {
          rule.parser = {};
        }

        if (rule.parser.exportType !== "text") {
          logger.warn(
            `CSS rule exportType is not "text", overriding to "text". Current value: ${rule.parser.exportType}`,
          );
          rule.parser.exportType = "text";
        }
      }
    });

    compiler.hooks.compilation.tap(
      "RspackAppFederationPlugin",
      (_, { normalModuleFactory }) => {
        normalModuleFactory.hooks.beforeResolve.tap(
          "RspackAppFederationPlugin",
          (resolveData) => {
            if (
              cssSetRules.some((rule) =>
                matchesRuleSetRule(resolveData, rule),
              ) &&
              !resolveData.request.includes("?original")
            ) {
              const originalRequest = path.resolve(
                resolveData.context,
                resolveData.request,
              );
              const virtualCssModule =
                cssModuleGenerator.getModuleName(originalRequest);

              resolveData.request = tempFs.getPath(virtualCssModule);
              tempFs.write(
                virtualCssModule,
                cssModuleGenerator.getModuleCode(originalRequest),
              );
            }
          },
        );
      },
    );
  }

  apply(compiler: RspackCompiler) {
    const tempFs = new TempFS(
      path.join(
        compiler.context,
        "node_modules/.vappfed",
        this.options.remoteEntryName,
      ),
    );
    tempFs.initialize();

    this.applyBootstrapLogic(compiler, tempFs);
    this.applyCssLogic(compiler, tempFs);

    compiler.hooks.shutdown.tap("RspackAppFederationPlugin", () => {
      tempFs.cleanup();
    });
  }
}

const RspackPlugin = RspackAppFederationPlugin;

export { RspackPlugin as AppFederationRspackPlugin };

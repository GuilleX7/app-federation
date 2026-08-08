import { defineConfig } from "@rspack/cli";
import rspack from "@rspack/core";

export default defineConfig({
  entry: {
    standalone: {
      import: "./index.standalone.ts",
    },
    remote: {
      import: "./index.remote.ts",
      library: {
        type: "amd",
        amdContainer: "window.parentLoader",
      },
    },
    "examples-sample-lib-v1.0.0": {
      import: "examples-sample-lib",
      library: {
        type: "amd",
        amdContainer: "window.sharedLibraryLoader",
        name: "examples-sample-lib@1.0.0",
      },
      layer: "shared",
    },
  },
  output: {
    clean: true,
    chunkFormat: "module",
    chunkLoading: "import",
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        loader: "builtin:swc-loader",
        options: {
          detectSyntax: "auto",
          jsc: {
            target: "es2017",
          },
        },
      },
    ],
  },
  plugins: [
    new rspack.HtmlRspackPlugin({
      chunks: ["standalone"],
    }),
    new rspack.experiments.VirtualModulesPlugin({
      "./virtual-examples-sample-lib":
        "module.exports = __webpack_require__.shared['examples-sample-lib']",
    }),
    new rspack.NormalModuleReplacementPlugin(
      /examples\-sample\-lib/,
      (data) => {
        if (data.contextInfo.issuerLayer !== "shared") {
          data.request = "./virtual-examples-sample-lib";
        }
      },
    ),
  ],
  optimization: {
    concatenateModules: false,
    minimize: false,
    chunkIds: "named",
    moduleIds: "named",
    splitChunks: {
      cacheGroups: {
        "virtual-examples-sample-lib": {
          test: /virtual-examples-sample-lib/,
          name: "virtual-examples-sample-lib",
          chunks: "all",
          enforce: true,
        },
      },
    },
  },
  lazyCompilation: false,
  devServer: {
    port: 8081,
  },
});

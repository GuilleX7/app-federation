import { defineConfig } from "@rspack/cli";
import rspack from "@rspack/core";
import { AppFederationRspackPlugin } from "examples-11-library-plugin-library/build";

export default defineConfig({
  entry: {
    standalone: {
      import: "./src/index.standalone.ts",
    },
  },
  output: {
    clean: true,
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
    new AppFederationRspackPlugin({
      entries: {
        app: "./src/entry.main.ts",
      },
    }),
  ],
  optimization: {
    concatenateModules: false,
    minimize: false,
    chunkIds: "named",
    moduleIds: "named",
  },
  lazyCompilation: false,
  devServer: {
    port: 8081,
  },
});

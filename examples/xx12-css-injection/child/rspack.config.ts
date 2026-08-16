import { defineConfig } from "@rspack/cli";
import rspack from "@rspack/core";
import { AppFederationRspackPlugin } from "examples-12-css-injection-library/build";

export default defineConfig({
  entry: {
    standalone: "./src/index.standalone.ts",
  },
  output: {
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        type: "css/auto",
        parser: {
          exportType: "css-style-sheet",
        },
      },
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
    new rspack.CssExtractRspackPlugin(),
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

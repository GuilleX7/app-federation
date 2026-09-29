import { defineConfig } from "@rspack/cli";
import rspack from "@rspack/core";
import { AppFederationRspackPlugin } from "../library/dist/build";

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
        test: /\.ts$/,
        loader: "builtin:swc-loader",
        options: {
          detectSyntax: "auto",
          jsc: {
            target: "es2017",
          },
        },
      },
      {
        test: /\.css$/,
        type: "css",
      },
    ],
  },
  plugins: [
    new rspack.HtmlRspackPlugin({
      chunks: ["standalone"],
    }),
    new AppFederationRspackPlugin({
      entries: "./src/entry.main.ts",
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

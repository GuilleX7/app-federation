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
  resolve: {
    extensions: [".ts", "..."],
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
        type: "css/auto",
        parser: {
          exportType: "text",
        },
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
    port: 8082,
    headers: {
      "Access-Control-Allow-Origin": "*",
    },
  },
});

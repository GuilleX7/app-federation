import { defineConfig } from "@rspack/cli";
import rspack from "@rspack/core";

export default defineConfig({
  entry: {
    standalone: {
      import: "./src/index.standalone.ts",
    },
    remote: {
      import: "./src/index.remote.ts",
      library: {
        type: "amd",
        amdContainer: "window.parentLoader",
      },
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
  ],
  optimization: {
    concatenateModules: false,
    minimize: false,
    chunkIds: "named",
    moduleIds: "named",
  },
  devServer: {
    port: 8081,
  },
});

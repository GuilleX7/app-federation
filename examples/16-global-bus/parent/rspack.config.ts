import { defineConfig } from "@rspack/cli";
import rspack from "@rspack/core";

export default defineConfig({
  entry: {
    main: "./src/index.ts",
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
      },
    ],
  },
  plugins: [new rspack.HtmlRspackPlugin()],
  optimization: {
    concatenateModules: false,
    minimize: false,
    chunkIds: "named",
    moduleIds: "named",
  },
  devServer: {
    port: 8080,
  },
});

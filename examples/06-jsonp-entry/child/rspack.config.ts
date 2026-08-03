import { defineConfig } from "@rspack/cli";
import rspack from "@rspack/core";

export default defineConfig({
  entry: {
    main: {
      import: "./index.ts",
      library: {
        type: "jsonp",
        name: "window.parentLoader",
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
        },
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
    port: 8081,
  },
});

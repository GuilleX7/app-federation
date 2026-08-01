import { defineConfig } from "@rspack/cli";
import rspack from "@rspack/core";

export default defineConfig({
  entry: {
    main: {
      import: "./index.js",
      library: {
        type: "jsonp",
        name: "window.parentLoader",
      },
    },
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

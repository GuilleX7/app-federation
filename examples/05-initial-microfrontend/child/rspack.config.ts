import { defineConfig } from "@rspack/cli";
import rspack from "@rspack/core";

export default defineConfig({
  entry: {
    main: "./index.js",
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

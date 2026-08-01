import { defineConfig } from "@rspack/cli";

export default defineConfig({
  entry: {
    main: "./index.js",
  },
  optimization: {
    concatenateModules: false,
    minimize: false,
    chunkIds: "named",
    moduleIds: "named",
  },
});

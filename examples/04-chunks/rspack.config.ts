import { defineConfig } from "@rspack/cli";

export default defineConfig({
  entry: {
    main: "./index.ts",
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
  optimization: {
    concatenateModules: false,
    minimize: false,
    chunkIds: "named",
    moduleIds: "named",
    splitChunks: {
      cacheGroups: {
        utils: {
          test: /utils/,
          chunks: "all",
          enforce: true,
        },
      },
    },
  },
});

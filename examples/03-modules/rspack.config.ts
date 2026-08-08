import { defineConfig } from "@rspack/cli";

export default defineConfig({
  entry: {
    main: "./index.ts",
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
  optimization: {
    concatenateModules: false,
    minimize: false,
    chunkIds: "named",
    moduleIds: "named",
  },
});

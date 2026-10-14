import { defineConfig } from "@rspack/cli";
import { AppFederationRspackPlugin } from "@guillex7/app-federation/build";

export default defineConfig({
  module: {
    rules: [
      {
        test: /\.css$/,
        type: "css/auto",
      },
    ],
  },
  plugins: [
    new AppFederationRspackPlugin({
      entries: "./src/entry.main.ts",
    }),
  ],
});

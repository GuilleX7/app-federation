import { defineConfig } from "@rspack/cli";
import { AppFederationRspackPlugin } from "@guillex7/app-federation/build";

export default defineConfig({
  plugins: [
    new AppFederationRspackPlugin({
      entries: "./src/entry.main.ts", // Equivalent to { default: "./src/entry.main.ts" }
      remoteEntryName: "remote.js", // Optional
      internal: {
        amdContainer: "appFederationAmdContainer", // Optional
      },
    }),
  ],
});

import { defineConfig } from "@rspack/cli";

export default defineConfig({
  entry: {
    standalone: "./src/index.standalone.ts",
  },
});

/// <reference types="@rspack/core/module" />

export function getPublicPath(): string {
  return __webpack_public_path__;
}

export function setPublicPath(publicPath: string): void {
  __webpack_public_path__ = publicPath;
}

export async function getEntry(entryName: string) {
  return await import(`./entry.${entryName}.ts`);
}

import type { AppFederationAppEntry } from "../types";

type AppFederationAppEntryFactory = () => Promise<
  AppFederationAppEntry<any, any>
>;

declare global {
  var __webpack_public_path__: string;
}

let remoteEntryName = "";
const entries: Record<string, AppFederationAppEntryFactory> = {};

export function setRemoteEntryName(name: string): void {
  remoteEntryName = name;
}

export function registerEntries(
  newEntries: Record<string, AppFederationAppEntryFactory>,
): void {
  Object.assign(entries, newEntries);
}

export function getEntries(): Record<string, AppFederationAppEntryFactory> {
  return entries;
}

export function getPublicPath(): string {
  return __webpack_public_path__;
}

export function setPublicPath(publicPath: string): void {
  __webpack_public_path__ = publicPath;
}

export async function loadEntry<
  Props extends Record<string, unknown> = Record<string, unknown>,
  Actions extends Record<string, unknown> = Record<string, unknown>,
>(entryName: string): Promise<AppFederationAppEntry<Props, Actions>> {
  if (!entries[entryName]) {
    throw new Error(
      `Entry ${entryName} was not found in ${remoteEntryName} remote.\nAvailable entries: ${Object.keys(entries).join(", ")}`,
    );
  }
  return (await entries[entryName]()) as AppFederationAppEntry<Props, Actions>;
}

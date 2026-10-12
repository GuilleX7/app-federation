import type { AppFederationAppEntry } from '../types';

declare global {
  var __webpack_public_path__: string;
}

let remoteEntryName = '';
const entries: Record<string, () => Promise<AppFederationAppEntry>> = {};

export function setRemoteEntryName(name: string): void {
  remoteEntryName = name;
}

export function registerEntries(
  newEntries: Record<string, () => Promise<AppFederationAppEntry>>,
): void {
  Object.assign(entries, newEntries);
}

export function getEntries(): Record<
  string,
  () => Promise<AppFederationAppEntry>
> {
  return entries;
}

export function getPublicPath(): string {
  return __webpack_public_path__;
}

export function setPublicPath(publicPath: string): void {
  __webpack_public_path__ = publicPath;
}

export async function loadEntry(
  entryName: string,
): Promise<AppFederationAppEntry> {
  if (!entries[entryName]) {
    throw new Error(
      `Entry ${entryName} was not found in ${remoteEntryName} remote.\nAvailable entries: ${Object.keys(entries).join(', ')}`,
    );
  }
  return entries[entryName]();
}

export type DeepRequired<T> = Required<{
  [K in keyof T]: T[K] extends Required<T[K]> ? T[K] : DeepRequired<T[K]>;
}>;

export const DEFAULT_REMOTE_ENTRY_NAME = "remote";
export const DEFAULT_GLOBAL_AMD_CONTAINER = "appFederationAmdContainer";

export function getRemoteEntryPrefix(remoteEntryName: string): string {
  return `./__virtual__app-federation/${remoteEntryName}`;
}

export function getRemoteEntryModuleName(remoteEntryName: string): string {
  return `${getRemoteEntryPrefix(remoteEntryName)}/entry`;
}

export function joinUrls(...urls: string[]): string {
  try {
    let finalUrl: string | URL = document.URL;
    for (const url of urls) {
      finalUrl = new URL(url, finalUrl);
    }
    return finalUrl.toString();
  } catch {
    return "";
  }
}

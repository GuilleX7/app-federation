export type DeepRequired<T> = Required<{
  [K in keyof T]: T[K] extends Required<T[K]> ? T[K] : DeepRequired<T[K]>;
}>;

export const DEFAULT_GLOBAL_AMD_CONTAINER = "appFederationAmdContainer";
export const DEFAULT_REMOTE_ENTRY_NAME = "remote";
export const DEFAULT_APP_ENTRY_NAME = "default";
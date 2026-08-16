export type AppFederationPluginOptions = {
  entries: Record<string, string> | string;
  remoteEntryName?: string;
  internal?: AppFederationPluginInternalOptions;
};

export type AppFederationPluginInternalOptions = {
  amdContainer?: string;
};

export type AppFederationAmdContainer = {
  define: (appFactory: AppFederationAppFactory) => void;
  appFactoryByRemoteEntryUrl: Record<string, Promise<AppFederationAppFactory>>;
};

export type AppFederationAppFactory = () => Promise<AppFederationAppInstance>;

export type AppFederationAppInstance = {
  getPublicPath: () => string;
  setPublicPath: (publicPath: string) => void;
  loadEntry: (entryName: string) => Promise<AppFederationAppEntry>;
};

export type AppFederationAppEntry = {
  mount: AppFederationEntryMount;
};

export type AppFederationEntryMountOptions = {
  container?: HTMLElement;
  [key: string]: unknown;
};

export type AppFederationEntryMount = (
  options: AppFederationEntryMountOptions,
) => AppFederationEntryLifecycle | Promise<AppFederationEntryLifecycle>;

export type AppFederationEntryLifecycle = {
  unmount: AppFederationEntryUnmount;
};

export type AppFederationEntryUnmountOptions = {
  [key: string]: unknown;
};

export type AppFederationEntryUnmount = (
  options?: AppFederationEntryUnmountOptions,
) => void | Promise<void>;

export type LoadRemoteEntryOptions = {
  internal?: {
    globalAmdContainer?: string;
  };
};

export type LoadAppInstanceOptions = LoadRemoteEntryOptions;

export type LoadAppInstanceEntryOptions = LoadRemoteEntryOptions & {
  entry?: string;
};

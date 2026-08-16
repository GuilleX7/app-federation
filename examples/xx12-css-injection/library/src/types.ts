export type AppFederationPluginOptions = {
  entries: Record<string, string>;
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
  mount: AppFederationAppMount;
};

export type AppFederationAppMount = (options: {
  container?: HTMLElement | undefined;
  [key: string]: unknown;
}) => AppFederationAppLifecycle | Promise<AppFederationAppLifecycle>;

export type AppFederationAppLifecycle = {
  unmount: AppFederationAppUnmount;
};

export type AppFederationAppUnmount = (options?: {
  [key: string]: unknown;
}) => void | Promise<void>;

export type LoadRemoteEntryOptions = {
  internal?: {
    globalAmdContainer?: string;
  };
};

export type LoadAppInstanceOptions = LoadRemoteEntryOptions;

export type LoadAppAndMountOptions = {
  container?: HTMLElement;
} & LoadRemoteEntryOptions;

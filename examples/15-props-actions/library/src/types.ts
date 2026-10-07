export type AppFederationPluginOptions = {
  entries: Record<string, string> | string;
  remoteEntryName?: string;
  internal?: AppFederationPluginInternalOptions;
};

export type AppFederationPluginInternalOptions = {
  amdContainer?: string;
};

export type AppFederationPropsStore<Props extends object> = {
  get: <Key extends keyof Props>(key: Key) => Props[Key];
  set: <Key extends keyof Props>(key: Key, value: Props[Key]) => void;
  subscribe: <Key extends keyof Props>(
    key: Key,
    listener: (value: Props[Key], previousValue: Props[Key]) => void,
  ) => () => void;
};

export type AppFederationBridge<
  Props extends object,
  Actions extends object,
> = {
  props: AppFederationPropsStore<Props>;
  actions: Actions;
  dispose: () => void;
};

export type AppFederationAppFactory = () => Promise<AppFederationAppInstance>;

export type AppFederationAppInstance = {
  getPublicPath: () => string;
  setPublicPath: (publicPath: string) => void;
  loadEntry: <
    Props extends Record<string, unknown> = Record<string, unknown>,
    Actions extends Record<string, unknown> = Record<string, unknown>,
  >(
    entryName: string,
  ) => Promise<AppFederationAppEntry<Props, Actions>>;
};

export type AppFederationAppEntry<
  Props extends Record<string, unknown> = Record<string, unknown>,
  Actions extends Record<string, unknown> = Record<string, unknown>,
> = {
  mount: AppFederationEntryMount<Props, Actions>;
};

export type AppFederationEntryMountOptions<
  Props extends Record<string, unknown> = Record<string, unknown>,
  Actions extends Record<string, unknown> = Record<string, unknown>,
> = {
  container: HTMLElement;
  bridge?: AppFederationBridge<Props, Actions>;
};

export type AppFederationEntryMount<
  Props extends Record<string, unknown> = Record<string, unknown>,
  Actions extends Record<string, unknown> = Record<string, unknown>,
> = (
  options: AppFederationEntryMountOptions<Props, Actions>,
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

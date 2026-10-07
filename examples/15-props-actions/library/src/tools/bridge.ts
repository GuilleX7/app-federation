type PropListener = (value: unknown, previousValue: unknown) => void;

export type AppFederationPropsStore<Props extends object> = {
  get: <Key extends keyof Props>(key: Key) => Props[Key];
  set: <Key extends keyof Props>(key: Key, value: Props[Key]) => void;
  subscribe: <Key extends keyof Props>(
    key: Key,
    listener: (value: Props[Key], previousValue: Props[Key]) => void,
  ) => () => void;
  unsubscribeAll: () => void;
};

export type AppFederationBridge<
  Props extends object,
  Actions extends object,
> = {
  props: AppFederationPropsStore<Props>;
  actions: Actions;
};

export function createAppBridge<Props extends object, Actions extends object>(
  initialProps: Props,
  actions: Actions,
): AppFederationBridge<Props, Actions> {
  const propsValues: Props = { ...initialProps };
  const propListeners = new Map<keyof Props, Set<PropListener>>();

  const propsStore: AppFederationPropsStore<Props> = {
    get: (key) => propsValues[key],
    set: (key, value) => {
      const previousValue = propsValues[key];
      if (Object.is(previousValue, value)) {
        return;
      }

      propsValues[key] = value;
      propListeners.get(key)?.forEach((listener) => {
        listener(value, previousValue);
      });
    },
    subscribe: (key, listener) => {
      let listenersForKey = propListeners.get(key);
      if (!listenersForKey) {
        listenersForKey = new Set();
        propListeners.set(key, listenersForKey);
      }

      const propListener: PropListener = (value, previousValue) => {
        listener(
          value as Props[typeof key],
          previousValue as Props[typeof key],
        );
      };
      listenersForKey.add(propListener);
      let isSubscribed = true;

      return () => {
        if (!isSubscribed) {
          return;
        }
        isSubscribed = false;
        listenersForKey?.delete(propListener);
        if (
          listenersForKey?.size === 0 &&
          propListeners.get(key) === listenersForKey
        ) {
          propListeners.delete(key);
        }
      };
    },
    unsubscribeAll: () => {
      propListeners.clear();
    },
  };

  return {
    props: propsStore,
    actions,
  };
}

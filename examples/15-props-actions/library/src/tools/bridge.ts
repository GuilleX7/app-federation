import type {
  AppFederationBridge,
  AppFederationPropsStore,
} from "../types.js";

type Mutable<Props> = {
  -readonly [Key in keyof Props]: Props[Key];
};
type PropListener = (value: unknown, previousValue: unknown) => void;

export function createAppBridge<Props extends object, Actions extends object>(
  initialProps: Props,
  actions: Actions,
): AppFederationBridge<Props, Actions> {
  const propsValues: Mutable<Props> = { ...initialProps };
  const propListeners = new Map<keyof Props, Set<PropListener>>();
  let isDisposed = false;

  const propsStore: AppFederationPropsStore<Props> = {
    get: (key) => propsValues[key],
    set: (key, value) => {
      const previousValue = propsValues[key];
      if (Object.is(previousValue, value)) {
        return;
      }

      propsValues[key] = value;
      if (isDisposed) {
        return;
      }

      propListeners.get(key)?.forEach((listener) => {
        listener(value, previousValue);
      });
    },
    subscribe: (key, listener) => {
      if (isDisposed) {
        return () => {};
      }

      let listenersForKey = propListeners.get(key);
      if (!listenersForKey) {
        listenersForKey = new Set();
        propListeners.set(key, listenersForKey);
      }

      const propListener: PropListener = (value, previousValue) => {
        listener(value as Props[typeof key], previousValue as Props[typeof key]);
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
  };

  return {
    props: propsStore,
    actions,
    dispose: () => {
      if (isDisposed) {
        return;
      }

      isDisposed = true;
      propListeners.clear();
    },
  };
}

type BusListener = {
  callback: ((payload: unknown) => void) | undefined;
};

export type AppFederationBus<Events extends object> = {
  subscribe: <Event extends keyof Events>(
    event: Event,
    listener: (payload: Events[Event]) => void,
  ) => () => void;
  emit: <Event extends keyof Events>(
    event: Event,
    payload: Events[Event],
  ) => void;
  dispose: () => void;
  isDisposed: () => boolean;
};

export function createBus<Events extends object>(): AppFederationBus<Events> {
  const listeners = new Map<keyof Events, Set<BusListener>>();
  let disposed = false;

  return {
    subscribe: (event, listener) => {
      if (disposed) {
        return () => {};
      }

      let listenersForEvent = listeners.get(event);
      if (!listenersForEvent) {
        listenersForEvent = new Set();
        listeners.set(event, listenersForEvent);
      }

      const busListener: BusListener = {
        callback: (payload) => {
          listener(payload as Events[typeof event]);
        },
      };
      listenersForEvent.add(busListener);
      let isSubscribed = true;

      return () => {
        if (!isSubscribed) {
          return;
        }
        isSubscribed = false;
        busListener.callback = undefined;
        listenersForEvent?.delete(busListener);
        if (
          listenersForEvent?.size === 0 &&
          listeners.get(event) === listenersForEvent
        ) {
          listeners.delete(event);
        }
      };
    },
    emit: (event, payload) => {
      if (disposed) {
        return;
      }

      listeners.get(event)?.forEach((listener) => {
        listener.callback?.(payload);
      });
    },
    dispose: () => {
      if (disposed) {
        return;
      }
      disposed = true;

      listeners.forEach((listenersForEvent) => {
        listenersForEvent.forEach((listener) => {
          listener.callback = undefined;
        });
        listenersForEvent.clear();
      });
      listeners.clear();
    },
    isDisposed: () => disposed,
  };
}

import {
  createAppBridge,
  loadAppInstanceEntry,
} from "../../library/dist/tools";
import type { AppFederationBridge } from "../../library/dist/tools";
import type { CounterActions, CounterProps } from "../../contracts.js";

let bridge: AppFederationBridge<CounterProps, CounterActions> | undefined;
const appBridge = createAppBridge<CounterProps, CounterActions>(
  { label: "Standalone counter", value: 0 },
  {
    onValueChange: (value) => bridge?.props.set("value", value),
    onResetRequest: () => bridge?.props.set("value", 0),
  },
);
bridge = appBridge;

loadAppInstanceEntry<CounterProps, CounterActions>("remote.js")
  .then(async (entry) => {
    await entry.mount({
      container: document.body,
      bridge: appBridge,
    });
  })
  .catch((error: unknown) => {
    console.error("Failed to load the standalone microfrontend.", error);
  });

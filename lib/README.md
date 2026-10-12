# App Federation library

`lib` is the maintained TypeScript implementation in this repository. Its source is in `src/`; the TypeScript build writes JavaScript and declaration files to `dist/`. The package is currently marked private and is intended for use from this repository's npm workspaces; it is not published to npm.

## Build

From the repository root, install dependencies and build the library:

```sh
npm install
npm run build-lib
```

Or, from this directory, run:

```sh
npm run build
```

The package exports three entry points:

| Import path                        | Purpose                                                       |
| ---------------------------------- | ------------------------------------------------------------- |
| `@guillex7/app-federation`         | Host loading helpers, communication helpers, and public types |
| `@guillex7/app-federation/build`   | Rspack build plugin                                           |
| `@guillex7/app-federation/runtime` | Remote runtime and CSS-scoping helpers                        |

These imports resolve to `dist/`, so build `lib` before importing it from a workspace. The build entry point requires an application using Rspack and a resolvable `@rspack/core` dependency.

## Expose a remote application

Add the build plugin to the remote's Rspack configuration. `entries` accepts one source path or a map of entry names to source paths. The defaults produce a `remote.js` remote entry and name a single entry `default`.

```ts
import { AppFederationRspackPlugin } from '@guillex7/app-federation/build';

export default {
  plugins: [
    new AppFederationRspackPlugin({
      entries: './src/entry.main.ts',
    }),
  ],
};
```

Each configured entry module exports a `mount` function. It receives the host's container and returns an `unmount` function for cleanup:

```ts
import type { AppFederationEntryMount } from '@guillex7/app-federation';

export const mount: AppFederationEntryMount = ({ container }) => {
  if (!container) {
    throw new Error('A mount container is required');
  }

  container.textContent = 'Remote application';

  return {
    unmount: () => {
      container.replaceChildren();
    },
  };
};
```

For multiple remote entries, pass a map such as `{ catalog: './src/catalog.ts', profile: './src/profile.ts' }`. Select a named entry from the host with the `entry` option shown below.

## Load and mount from the host

The host uses `loadAppInstanceEntry` with the URL of the built remote entry, then mounts it in an element. Keep the returned lifecycle to unmount the remote when it is no longer needed.

```ts
import { loadAppInstanceEntry } from '@guillex7/app-federation';

const container = document.querySelector('#remote-container');
if (!(container instanceof HTMLElement)) {
  throw new Error('Remote container was not found');
}

const remoteEntry = await loadAppInstanceEntry(
  'https://example.com/catalog/remote.js',
);
const lifecycle = await remoteEntry.mount({ container });

// Call when the remote should be removed.
await lifecycle.unmount();
```

To select a named entry, pass `{ entry: 'catalog' }` as the second argument. `loadRemoteEntry` loads and caches the remote factory, while `loadAppInstance` creates an app instance without selecting an entry. The runtime derives the remote's public path from the remote-entry URL so its chunks can be located.

## Communication and styles

- `createAppBridge<Props, Actions>(initialProps, actions)` creates a typed props store and action object for a host and remote to share. Props can be read, updated, and subscribed to; subscriptions return cleanup functions.
- `createBus<Events>()` creates a typed event bus. `subscribe` returns an unsubscribe function; call `dispose` when the bus is no longer needed.
- The runtime entry point exports CSS helpers such as `createStyledContainer`, `removeStyledContainer`, and `tearDownStyleScoping`. `createStyledContainer` creates a Shadow DOM container by default. When using the build plugin's CSS handling, configure Rspack's native CSS rules as shown in examples 13-16.

The remote runs as a script in the host page's browser context. Only load remote code that the host trusts.

## Source map

- `src/tools/` contains host loading, bridge, and event-bus APIs.
- `src/runtime/` contains the remote entry runtime and CSS-scoping helpers.
- `src/build/` contains the Rspack plugin and generated bootstrap/CSS modules.
- `src/types.ts` defines shared plugin, entry, and lifecycle types.

See [`../examples/12-library-plugin/`](../examples/12-library-plugin/) for the plugin flow, [`../examples/15-props-actions/`](../examples/15-props-actions/) for the bridge, and [`../examples/16-global-bus/`](../examples/16-global-bus/) for bus usage. Those examples retain library snapshots from their respective stages; `lib/` is the maintained package source.

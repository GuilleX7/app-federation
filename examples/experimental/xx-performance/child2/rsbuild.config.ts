import { defineConfig } from '@rsbuild/core';
import { pluginReact } from '@rsbuild/plugin-react';
import { Compiler, rspack } from '@rspack/core';
import { name } from './package.json';

export default defineConfig({
  source: {
    entry: {
      index: './src/standalone.tsx',
    },
  },
  output: {
    assetPrefix: 'http://localhost:<port>/',
  },
  plugins: [pluginReact({ fastRefresh: false })],
  performance: {
    chunkSplit: {
      override: {
        cacheGroups: {
          appFederationRemoteEntry: {
            test: (module) =>
              module.identifier().includes('app-federation-entry') ||
              module.identifier().includes('app-federation-runtime-module'),
            enforce: true,
            chunks: 'all',
            name: 'app-federation-entry',
          },
        },
      },
    },
  },
  dev: {
    lazyCompilation: false,
    assetPrefix: 'http://localhost:<port>/',
    client: {
      port: '<port>',
    },
    hmr: false,
    liveReload: false,
  },
  server: {
    port: 3002,
  },
  tools: {
    rspack: {
      plugins: [
        {
          apply(compiler: Compiler): void {
            compiler.hooks.compilation.tap(
              'JsonpLoaderPatcher',
              (compilation) => {
                compilation.hooks.runtimeModule.tap(
                  'JsonpLoaderPatcher',
                  (module) => {
                    if (
                      module.name !== 'jsonp_chunk_loading' ||
                      !module.source
                    ) {
                      return;
                    }

                    const originSource =
                      module.source?.source.toString('utf-8');
                    module.source.source = Buffer.from(
                      originSource.replace(
                        `chunkLoadingGlobal.forEach(webpackJsonpCallback.bind(null, 0));
chunkLoadingGlobal.push = webpackJsonpCallback.bind(null, chunkLoadingGlobal.push.bind(chunkLoadingGlobal));`,
                        `chunkLoadingGlobal.callbacks = chunkLoadingGlobal.callbacks || [];
const ownJsonpCallback = webpackJsonpCallback.bind(null, 0);
chunkLoadingGlobal.callbacks.push(ownJsonpCallback);
chunkLoadingGlobal.forEach(ownJsonpCallback);
if (!chunkLoadingGlobal.originalPush) {
	chunkLoadingGlobal.originalPush =  chunkLoadingGlobal.push.bind(chunkLoadingGlobal);
	chunkLoadingGlobal.push = (data) => {
		chunkLoadingGlobal.originalPush(data);
		chunkLoadingGlobal.callbacks.forEach((fn) => fn(data));
	}
}
__webpack_require__.jsonp_callback = ownJsonpCallback;`,
                      ),
                      'utf-8',
                    );
                  },
                );
              },
            );
          },
        },
        new rspack.experiments.VirtualModulesPlugin({
          'app-federation-runtime-module.js': `
            export function getPublicPath() {
              return __webpack_public_path__;
            }

            export function setPublicPath(path) {
              __webpack_public_path__ = path;
            }

            export function teardown() {
              const ownCallback = __webpack_require__.jsonp_callback;
              const ownCallbackIdx = window['webpackChunk${name}'].callbacks.indexOf(ownCallback);
              if (ownCallbackIdx !== -1) {
                window['webpackChunk${name}'].callbacks.splice(ownCallbackIdx, 1);
              }
            }
            `,
        }),
        new rspack.container.ModuleFederationPluginV1({
          name: 'app-federation-entry',
          filename: 'remoteEntry.js',
          exposes: {
            '.': './src/federated.tsx',
            'app-federation/runtime-module':
              './app-federation-runtime-module.js',
          },
          library: {
            type: 'amd',
            amdContainer: `__APP_FEDERATION__`,
          },
        }),
      ],
    },
  },
});

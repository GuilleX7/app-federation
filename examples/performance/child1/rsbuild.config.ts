import { defineConfig } from '@rsbuild/core';
import { pluginVue } from '@rsbuild/plugin-vue';
import { Compiler, rspack } from '@rspack/core';

export default defineConfig({
  source: {
    entry: {
      index: './src/standalone.ts',
    },
  },
  output: {
    assetPrefix: 'http://localhost:<port>/',
  },
  plugins: [pluginVue()],
  performance: {
    chunkSplit: {
      override: {
        cacheGroups: {
          child1: {
            test: (module) =>
              module.identifier().includes('container entry') ||
              module.identifier().includes('app-federation-runtime-module'),
            enforce: true,
            name: 'mf',
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
    port: 3001,
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
chunkLoadingGlobal.attachers = chunkLoadingGlobal.attachers || [];
var ownJsonpCallback = webpackJsonpCallback.bind(null, 0);

__webpack_require__.jsonp_loader_attach = function() {
  chunkLoadingGlobal.push = function (data) {
    Array.prototype.push.call(chunkLoadingGlobal, data);
    chunkLoadingGlobal.callbacks.forEach((callback) => callback(data));
  }
  if (chunkLoadingGlobal.attachers) {
    var ownAttacherIdx = chunkLoadingGlobal.attachers.indexOf(__webpack_require__.jsonp_loader_attach);
    if (ownAttacherIdx !== -1) {
      chunkLoadingGlobal.attachers.splice(ownAttacherIdx, 1);
    }
  }
}

__webpack_require__.jsonp_loader_detach = function() {
  var ownCallbackIdx = chunkLoadingGlobal.callbacks.indexOf(ownJsonpCallback);
  if (ownCallbackIdx !== -1) {
    chunkLoadingGlobal.callbacks.splice(ownCallbackIdx, 1);
  }
  chunkLoadingGlobal.push = Array.prototype.push;
  if (chunkLoadingGlobal.attachers && chunkLoadingGlobal.attachers[0]) {
    chunkLoadingGlobal.attachers[0]();
  }
}

if (chunkLoadingGlobal.push === Array.prototype.push) {
  __webpack_require__.jsonp_loader_attach(chunkLoadingGlobal);
} else {
  chunkLoadingGlobal.attachers.push(__webpack_require__.jsonp_loader_attach);
}

chunkLoadingGlobal.callbacks.push(ownJsonpCallback);
chunkLoadingGlobal.forEach(ownJsonpCallback);`,
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
              __webpack_require__.jsonp_loader_detach();
            }
            `,
        }),
        new rspack.container.ModuleFederationPluginV1({
          name: 'mf',
          filename: 'remoteEntry.js',
          exposes: {
            '.': './src/federated.ts',
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

import { createApp } from 'vue';
import App from './App.vue';
import type { AppMountingLifecycle } from 'app-federation';

let globalVariable = 1;

const lifecycle: AppMountingLifecycle = {
  mount: ({ container }: { container: HTMLElement }) => {
    const app = createApp(App);
    app.mount(container);
    console.log('Global Variable:', globalVariable);
    globalVariable = globalVariable + 1;

    return {
      unmount: () => {
        app.unmount();

        delete window['__VUE_SSR_SETTERS__'];
        delete window['__VUE_INSTANCE_SETTERS__'];
        delete window['__VUE_HMR_RUNTIME__'];
        delete window['__VUE_DEVTOOLS_HOOK_REPLAY__'];
        // delete window['devtoolsFormatters'];
      },
    };
  },
};

export default lifecycle;

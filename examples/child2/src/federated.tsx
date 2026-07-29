import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import type { AppMountingLifecycle } from 'app-federation';

const lifecycle: AppMountingLifecycle = {
  mount: ({ container }: { container: HTMLElement }) => {
    const innerContainer = document.createElement('div');
    const root = ReactDOM.createRoot(innerContainer);
    root.render(
      <React.StrictMode>
        <App />
      </React.StrictMode>,
    );
    container.appendChild(innerContainer);

    return {
      unmount: () => {
        root.unmount();
        container.removeChild(innerContainer);
      },
    };
  },
};

export default lifecycle;

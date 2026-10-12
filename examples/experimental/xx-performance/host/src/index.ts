import { loadFrontendApp, type AppUnmountingLifecycle } from 'app-federation';

let loadedFrontendApps: (AppUnmountingLifecycle | null)[] = new Array(50).fill(
  null,
);

const loadButton = document.createElement('button');
loadButton.textContent = 'Load frontend app';
loadButton.addEventListener(
  'click',
  async () => {
    for (let i = 0; i < 50; i++) {
      const container = document.createElement('div');
      container.id = `child1-container-${i}`;
      document.body.appendChild(container);
      loadedFrontendApps[i] = await loadFrontendApp({
        container,
        name: 'child1',
        url: 'http://localhost:3001/',
      });
    }
    loadButton.disabled = true;
    unloadButton.disabled = false;
  },
  false,
);
document.body.appendChild(loadButton);

const unloadButton = document.createElement('button');
unloadButton.textContent = 'Unload frontend app';
unloadButton.disabled = true;
unloadButton.addEventListener(
  'click',
  async () => {
    await Promise.all(loadedFrontendApps.map((fapp) => fapp && fapp.unmount()));
    loadedFrontendApps = new Array(50).fill(null);
    loadButton.disabled = false;
    unloadButton.disabled = true;
    for (let i = 0; i < 50; i++) {
      const container = document.getElementById(`child1-container-${i}`);
      if (container) {
        document.body.removeChild(container);
      }
    }
  },
  false,
);
document.body.appendChild(unloadButton);

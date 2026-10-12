const registeredContainers = new Map<HTMLElement, HTMLElement | ShadowRoot>();

const registeredModules = new Map<
  string,
  {
    cssText: string;
    clones: HTMLStyleElement[];
    fontFaceRules: Set<string>;
  }
>();

const hoistedFontFaceRules = new Map<
  string,
  { owners: Set<string>; styleElement: HTMLStyleElement }
>();

const HOST_RESET_STYLES = ':host { all: initial; }';

function createStyleElement(
  cssText: string,
  useShadowRoot = false,
): HTMLStyleElement {
  const styleElement = document.createElement('style');
  styleElement.textContent = useShadowRoot
    ? fixCssForShadowRoot(cssText)
    : cssText;
  return styleElement;
}

function updateModule(moduleId: string, cssText: string): void {
  const registeredModule = registeredModules.get(moduleId);
  if (!registeredModule) {
    return;
  }

  registeredModule.cssText = cssText;
  registeredModule.clones.forEach((clone): void => {
    clone.textContent =
      clone.parentNode instanceof ShadowRoot
        ? fixCssForShadowRoot(cssText)
        : cssText;
  });
}

function getFontFaceRules(cssText: string): string[] {
  const parsingStyleElement = createStyleElement(cssText);
  document.head.appendChild(parsingStyleElement);
  const styleSheet = parsingStyleElement.sheet;
  const fontFaceRules = styleSheet
    ? Array.from(styleSheet.cssRules ?? [])
        .filter((rule): boolean => rule.constructor.name === 'CSSFontFaceRule')
        .map((rule): string => rule.cssText)
    : [];
  document.head.removeChild(parsingStyleElement);

  return fontFaceRules;
}

function addFontFaceRules(moduleId: string, fontFaceRules: Set<string>): void {
  fontFaceRules.forEach((cssText): void => {
    const existingRule = hoistedFontFaceRules.get(cssText);
    if (existingRule) {
      existingRule.owners.add(moduleId);
      return;
    }

    const styleElement = document.createElement('style');
    styleElement.textContent = cssText;
    document.head.appendChild(styleElement);
    hoistedFontFaceRules.set(cssText, {
      owners: new Set([moduleId]),
      styleElement,
    });
  });
}

function removeFontFaceRules(
  moduleId: string,
  fontFaceRules: Set<string>,
): void {
  fontFaceRules.forEach((cssText): void => {
    const registeredRule = hoistedFontFaceRules.get(cssText);
    if (!registeredRule) {
      return;
    }

    registeredRule.owners.delete(moduleId);
    if (registeredRule.owners.size !== 0) {
      return;
    }

    registeredRule.styleElement.remove();
    hoistedFontFaceRules.delete(cssText);
  });
}

function registerModuleCss(moduleId: string, cssText: string): void {
  const fontFaceRules = new Set(getFontFaceRules(cssText));
  const registeredModule = registeredModules.get(moduleId);

  if (registeredModule) {
    removeFontFaceRules(moduleId, registeredModule.fontFaceRules);
    registeredModule.fontFaceRules = fontFaceRules;
    addFontFaceRules(moduleId, fontFaceRules);
    updateModule(moduleId, cssText);
    return;
  }

  const newModule = {
    cssText,
    clones: [] as HTMLStyleElement[],
    fontFaceRules,
  };
  registeredModules.set(moduleId, newModule);
  addFontFaceRules(moduleId, fontFaceRules);

  registeredContainers.forEach((linkedContainer): void => {
    const clone = createStyleElement(
      cssText,
      linkedContainer instanceof ShadowRoot,
    );
    linkedContainer.appendChild(clone);
    newModule.clones.push(clone);
  });
}

function unregisterModuleCss(moduleId: string): void {
  const registeredModule = registeredModules.get(moduleId);
  if (!registeredModule) {
    return;
  }

  registeredModule.clones.forEach((clone): void => clone.remove());
  removeFontFaceRules(moduleId, registeredModule.fontFaceRules);
  registeredModules.delete(moduleId);
}

function createStyledContainer(container: HTMLElement): HTMLDivElement;
function createStyledContainer(
  container: HTMLElement,
  options?: { createShadowRoot?: boolean },
): HTMLDivElement;
function createStyledContainer(
  container: HTMLElement,
  options?: { returnNestedContainer?: true },
): HTMLDivElement;
function createStyledContainer(
  container: HTMLElement,
  options?: { returnNestedContainer?: false },
): ShadowRoot;
function createStyledContainer(
  container: HTMLElement,
  options?: { createShadowRoot?: boolean; returnNestedContainer?: true },
): HTMLDivElement;
function createStyledContainer(
  container: HTMLElement,
  options?: { createShadowRoot?: false; returnNestedContainer?: false },
): HTMLElement;
function createStyledContainer(
  container: HTMLElement,
  options?: { createShadowRoot?: true; returnNestedContainer?: false },
): ShadowRoot;
function createStyledContainer(
  container: HTMLElement,
  {
    createShadowRoot = true,
    returnNestedContainer = true,
  }: {
    createShadowRoot?: boolean;
    returnNestedContainer?: boolean;
  } = {},
): HTMLElement | ShadowRoot | HTMLDivElement {
  for (const [registeredContainer, linkedContainer] of registeredContainers) {
    if (registeredContainer === container || linkedContainer === container) {
      return linkedContainer;
    }
  }

  let linkedContainer: HTMLElement | ShadowRoot = container;
  if (createShadowRoot) {
    const shadowRoot = container.attachShadow({ mode: 'open' });
    const resetStyles = document.createElement('style');
    resetStyles.textContent = HOST_RESET_STYLES;
    shadowRoot.appendChild(resetStyles);
    linkedContainer = shadowRoot;
  }
  registeredContainers.set(container, linkedContainer);

  registeredModules.forEach((registeredModule): void => {
    const clone = createStyleElement(
      registeredModule.cssText,
      linkedContainer instanceof ShadowRoot,
    );
    linkedContainer.appendChild(clone);
    registeredModule.clones.push(clone);
  });

  let returnedContainer: HTMLElement | ShadowRoot | HTMLDivElement =
    linkedContainer;
  if (returnNestedContainer) {
    const nestedContainer = document.createElement('div');
    nestedContainer.style.height = '100%';
    linkedContainer.appendChild(nestedContainer);
    returnedContainer = nestedContainer;
  }

  return returnedContainer;
}

function removeStyledContainer(
  container: HTMLElement | ShadowRoot,
  { removeShadowRoot = false }: { removeShadowRoot?: boolean } = {},
): void {
  for (const [registeredContainer, linkedContainer] of registeredContainers) {
    if (registeredContainer === container || linkedContainer === container) {
      removeContainer(registeredContainer, linkedContainer, {
        removeShadowRoot,
      });
      return;
    }
  }
}

function removeContainer(
  registeredContainer: HTMLElement,
  linkedContainer: HTMLElement | ShadowRoot,
  { removeShadowRoot }: { removeShadowRoot: boolean },
): void {
  registeredModules.forEach((registeredModule): void => {
    const clone = registeredModule.clones.find(
      (candidate): boolean => candidate.parentNode === linkedContainer,
    );
    if (clone) {
      clone.remove();
      registeredModule.clones.splice(registeredModule.clones.indexOf(clone), 1);
    }
  });

  if (linkedContainer instanceof ShadowRoot) {
    linkedContainer.innerHTML = '';
    if (removeShadowRoot) {
      registeredContainer.replaceWith(registeredContainer.cloneNode(false));
    }
  }

  registeredContainers.delete(registeredContainer);
}

function tearDownStyleScoping({
  removeShadowRoot = false,
}: { removeShadowRoot?: boolean } = {}): void {
  registeredContainers.forEach((linkedContainer, container): void => {
    removeContainer(container, linkedContainer, { removeShadowRoot });
  });

  registeredModules.forEach((registeredModule): void => {
    registeredModule.clones.forEach((clone): void => clone.remove());
  });
  registeredModules.clear();

  hoistedFontFaceRules.forEach(({ styleElement }): void =>
    styleElement.remove(),
  );
  hoistedFontFaceRules.clear();
  registeredContainers.clear();
}

function fixCssForShadowRoot(cssText: string): string {
  return fixRootScopingInTextContent(cssText);
}

function fixRootScopingInTextContent(cssText: string): string {
  return cssText.replace(
    /(^|[^a-zA-Z0-9_-]):root(?![a-zA-Z0-9_-])/g,
    '$1:host',
  );
}

function getRegisteredModulesCss(): Map<string, string> {
  const registeredModulesCss = new Map<string, string>();
  registeredModules.forEach((value, key) => {
    registeredModulesCss.set(key, value.cssText);
  });
  return registeredModulesCss;
}

function getStyledContainers(): Map<HTMLElement, HTMLElement | ShadowRoot> {
  return new Map(registeredContainers);
}

export {
  registerModuleCss,
  unregisterModuleCss,
  getRegisteredModulesCss,
  createStyledContainer,
  removeStyledContainer,
  getStyledContainers,
  tearDownStyleScoping,
};

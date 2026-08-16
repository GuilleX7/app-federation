/**
 * The registered containers with scoped styles.
 * The key is the original container that was passed to createStyledContainer.
 * The value is the linked container, which can be either an HTMLElement or a
 * ShadowRoot, and is the container that will receive the styles.
 */
const registeredContainers = new Map<HTMLElement, HTMLElement | ShadowRoot>();

/**
 * The CSS modules and their clones. Each clone belongs to a linked container.
 */
const registeredModules = new Map<
  string,
  {
    cssText: string;
    clones: HTMLStyleElement[];
    fontFaceRules: Set<string>;
  }
>();

/**
 * Hoisted @font-face rules and the modules that currently use them.
 */
const hoistedFontFaceRules = new Map<
  string,
  { owners: Set<string>; styleElement: HTMLStyleElement }
>();

const HOST_RESET_STYLES = ":host { all: initial; }";

/**
 * Creates a style element from CSS text.
 *
 * @param cssText - The CSS text to put in the style element
 * @param useShadowRoot - Whether to fix root scoping for Shadow DOM
 * @returns The created style element
 */
function createStyleElement(
  cssText: string,
  useShadowRoot = false,
): HTMLStyleElement {
  const styleElement = document.createElement("style");
  styleElement.textContent = useShadowRoot
    ? fixRootScopingInTextContent(cssText)
    : cssText;
  return styleElement;
}

/**
 * Updates all clones of a registered module.
 */
function updateModule(moduleId: string, cssText: string): void {
  const registeredModule = registeredModules.get(moduleId);
  if (!registeredModule) {
    return;
  }

  registeredModule.cssText = cssText;
  registeredModule.clones.forEach((clone): void => {
    clone.textContent =
      clone.parentNode instanceof ShadowRoot
        ? fixRootScopingInTextContent(cssText)
        : cssText;
  });
}

/**
 * Gets the @font-face rules from CSS text by asking the browser to parse it.
 */
function getFontFaceRules(cssText: string): string[] {
  const parsingStyleElement = createStyleElement(cssText);
  document.head.appendChild(parsingStyleElement);
  const styleSheet = parsingStyleElement.sheet;
  const fontFaceRules = styleSheet
    ? Array.from(styleSheet.cssRules ?? [])
        .filter((rule): boolean => rule.constructor.name === "CSSFontFaceRule")
        .map((rule): string => rule.cssText)
    : [];
  document.head.removeChild(parsingStyleElement);

  return fontFaceRules;
}

/**
 * Adds ownership of font-face rules to a module and hoists new rules globally.
 */
function addFontFaceRules(moduleId: string, fontFaceRules: Set<string>): void {
  fontFaceRules.forEach((cssText): void => {
    const existingRule = hoistedFontFaceRules.get(cssText);
    if (existingRule) {
      existingRule.owners.add(moduleId);
      return;
    }

    const styleElement = document.createElement("style");
    styleElement.textContent = cssText;
    document.head.appendChild(styleElement);
    hoistedFontFaceRules.set(cssText, {
      owners: new Set([moduleId]),
      styleElement,
    });
  });
}

/**
 * Removes ownership of font-face rules from a module, removing rules that are
 * no longer used by any registered module.
 */
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

/**
 * Registers a module's complete processed CSS text.
 *
 * Calling this function again with the same module ID updates the existing
 * styles in every registered container.
 */
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

/**
 * Unregisters a module and removes its styles from every registered container.
 */
function unregisterModuleCss(moduleId: string): void {
  const registeredModule = registeredModules.get(moduleId);
  if (!registeredModule) {
    return;
  }

  registeredModule.clones.forEach((clone): void => clone.remove());
  removeFontFaceRules(moduleId, registeredModule.fontFaceRules);
  registeredModules.delete(moduleId);
}

/**
 * Registers a container element to receive styles.
 *
 * @param container - The container element to register
 * @param options - Options for creating the container
 * @param options.createShadowRoot - Whether to create a shadow root for the container
 * @param options.returnNestedContainer - Whether to create and return a nested div container
 */
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
    const shadowRoot = container.attachShadow({ mode: "open" });
    const resetStyles = document.createElement("style");
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
    const nestedContainer = document.createElement("div");
    nestedContainer.style.height = "100%";
    linkedContainer.appendChild(nestedContainer);
    returnedContainer = nestedContainer;
  }

  return returnedContainer;
}

/**
 * Unregisters a container element and removes its styles.
 *
 * @param container - The container element to unregister
 * @param options - Options for removing the container
 * @param options.removeShadowRoot - Whether to remove the shadow root when removing the container
 */
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

/**
 * Removes a registered container and its associated style clones.
 */
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
    linkedContainer.innerHTML = "";
    if (removeShadowRoot) {
      registeredContainer.replaceWith(registeredContainer.cloneNode(false));
    }
  }

  registeredContainers.delete(registeredContainer);
}

/**
 * Tears down style scoping and removes all styles from registered containers.
 * This is useful for cleanup when the frontend application is unmounted.
 */
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

/**
 * Fixes style scoping by replacing :root with :host for Shadow DOM styles.
 */
function fixRootScopingInTextContent(textContent = ""): string {
  return textContent.replace(
    /(^|[^a-zA-Z0-9_-]):root(?![a-zA-Z0-9_-])/g,
    "$1:host",
  );
}

export default registerModuleCss;
export {
  registerModuleCss,
  unregisterModuleCss,
  createStyledContainer,
  removeStyledContainer,
  tearDownStyleScoping,
};

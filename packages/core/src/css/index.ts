/**
 * The registered containers with scoped styles.
 * The key is the original container that was passed to createStyledContainer.
 * The value is the linked container, which can be either an HTMLElement or a ShadowRoot,
 * and is the container that will receive the styles.
 */
const registeredContainers = new Map<HTMLElement, HTMLElement | ShadowRoot>();
/**
 * The style elements with their clones.
 * The key is the original style element that was registered, and the value is an
 * array of clones. Each clone should belong to a linked container.
 */
const clonedStyleElements = new Map<HTMLStyleElement, HTMLStyleElement[]>();
/**
 * The hoisted style elements.
 * These are the style elements that have been hoisted to the document head.
 */
const hoistedStyleElements = new Set<HTMLStyleElement>();
/**
 * The hoisted @font-face rules.
 * These are the @font-face rules that have been hoisted to the document head.
 * They're stored as plain strings to prevent duplicates.
 */
const hoistedFontFaceRules = new Set<string>();
/**
 * Pending style elements to process in the next microtask.
 */
const pendingStyleUpdates = new Set<HTMLStyleElement>();
let hasScheduledStyleFlush = false;
/**
 * The observer to sync styles across containers.
 * It observes original style elements. Whenever the original style element changes,
 * the clones are updated.
 */
const styleObserver = new MutationObserver(
  (mutations: MutationRecord[]): void => {
    mutations.forEach((mutation: MutationRecord): void => {
      let styleElement: HTMLStyleElement | null = null;
      if (mutation.target instanceof HTMLStyleElement) {
        styleElement = mutation.target;
      } else if (mutation.target.parentElement instanceof HTMLStyleElement) {
        styleElement = mutation.target.parentElement;
      }

      if (styleElement) {
        enqueueStyleUpdate(styleElement);
      }
    });
  },
);

const HOST_RESET_STYLES = ':host { all: initial; }';

function enqueueStyleUpdate(styleElement: HTMLStyleElement): void {
  pendingStyleUpdates.add(styleElement);
  if (hasScheduledStyleFlush) {
    return;
  }

  hasScheduledStyleFlush = true;
  queueMicrotask(() => {
    pendingStyleUpdates.forEach(
      (pendingStyleElement: HTMLStyleElement): void => {
        registerStyleElement(pendingStyleElement);
      },
    );
    pendingStyleUpdates.clear();
    hasScheduledStyleFlush = false;
  });
}

/**
 * Clones a style element.
 *
 * @param styleElement - The style element to clone
 * @param options - Options for cloning
 * @param options.useShadowRoot - Whether to fix root scoping for Shadow DOM
 * @returns The cloned style element
 */
function cloneStyleElement(
  styleElement: HTMLStyleElement,
  { useShadowRoot = false }: { useShadowRoot?: boolean },
): HTMLStyleElement {
  const clone: HTMLStyleElement = styleElement.cloneNode(
    true,
  ) as HTMLStyleElement;
  if (useShadowRoot) {
    clone.textContent = fixRootScopingInTextContent(clone.textContent ?? '');
  }
  return clone;
}

/**
 * Replaces all clones of a style element with a new clone
 *
 * @param styleElement - The original style element to update
 */
function updateStyleElement(styleElement: HTMLStyleElement): void {
  const clones: HTMLStyleElement[] | undefined =
    clonedStyleElements.get(styleElement);
  if (!clones) {
    return;
  }

  clones.forEach((clone) => {
    syncStyleAttributes(styleElement, clone);
    clone.textContent =
      clone.parentNode instanceof ShadowRoot
        ? fixRootScopingInTextContent(styleElement.textContent ?? '')
        : (styleElement.textContent ?? '');
  });
}

function syncStyleAttributes(
  source: HTMLStyleElement,
  target: HTMLStyleElement,
): void {
  const attributesToRemove = Array.from(target.attributes).filter(
    (attr) => !source.hasAttribute(attr.name),
  );

  attributesToRemove.forEach((attr) => {
    target.removeAttribute(attr.name);
  });

  Array.from(source.attributes).forEach((attr) => {
    const value = source.getAttribute(attr.name);
    if (value === null) {
      target.removeAttribute(attr.name);
      return;
    }
    target.setAttribute(attr.name, value);
  });

  target.disabled = source.disabled;
}

/**
 * Creates a style element and appends it to all registered containers
 *
 * @param styleElement - The style element to clone and append
 */
function createStyleElement(styleElement: HTMLStyleElement): void {
  const clones: HTMLStyleElement[] = [];

  for (const registeredContainer of registeredContainers.values()) {
    const clone: HTMLStyleElement = cloneStyleElement(styleElement, {
      useShadowRoot: registeredContainer instanceof ShadowRoot,
    });
    registeredContainer.appendChild(clone);
    clones.push(clone);
  }

  clonedStyleElements.set(styleElement, clones);

  styleObserver.observe(styleElement, {
    attributes: true,
    childList: true,
    subtree: true,
  });
}

/**
 * Registers a style element and observes it for changes
 *
 * @param styleElement - The style element to register
 */
function registerStyleElement(styleElement: HTMLStyleElement): void {
  hoistFontFaceRules(styleElement);

  if (clonedStyleElements.has(styleElement)) {
    return updateStyleElement(styleElement);
  } else {
    return createStyleElement(styleElement);
  }
}

/**
 * Registers a container element to receive styles
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
  for (const [
    registeredContainer,
    linkedContainer,
  ] of registeredContainers.entries()) {
    if (registeredContainer === container || linkedContainer === container) {
      return linkedContainer;
    }
  }

  let linkedContainer: HTMLElement | ShadowRoot = container;
  if (createShadowRoot) {
    const shadowRoot: ShadowRoot = container.attachShadow({ mode: 'open' });
    const resetStyles: HTMLStyleElement = document.createElement('style');
    resetStyles.textContent = HOST_RESET_STYLES;
    shadowRoot.appendChild(resetStyles);
    linkedContainer = shadowRoot;
  }
  registeredContainers.set(container, linkedContainer);

  clonedStyleElements.forEach(
    (clones: HTMLStyleElement[], styleElement: HTMLStyleElement): void => {
      const clone: HTMLStyleElement = cloneStyleElement(styleElement, {
        useShadowRoot: linkedContainer instanceof ShadowRoot,
      });
      linkedContainer.appendChild(clone);
      clones.push(clone);
    },
  );

  let returnedContainer = linkedContainer;
  if (returnNestedContainer) {
    const nestedContainer = document.createElement('div');
    nestedContainer.style.height = '100%';
    linkedContainer.appendChild(nestedContainer);
    returnedContainer = nestedContainer;
  }

  return returnedContainer;
}

/**
 * Unregisters a container element and removes its styles
 *
 * @param container - The container element to unregister
 * @param options - Options for removing the container
 * @param options.removeShadowRoot - Whether to remove the shadow root when removing the container
 *        Beware that this will replace the container with a clone of itself
 */
function removeStyledContainer(
  container: HTMLElement | ShadowRoot,
  {
    removeShadowRoot = false,
  }: {
    removeShadowRoot?: boolean;
  } = {},
): void {
  for (const [
    registeredContainer,
    linkedContainer,
  ] of registeredContainers.entries()) {
    if (registeredContainer === container || linkedContainer === container) {
      return removeContainer(registeredContainer, linkedContainer, {
        removeShadowRoot,
      });
    }
  }
}

/**
 * Removes a container element and its associated styles
 *
 * @param registeredContainer - The registered container element to remove
 * @param linkedContainer - The linked container element (either the original or the shadow root)
 */
function removeContainer(
  registeredContainer: HTMLElement,
  linkedContainer: HTMLElement | ShadowRoot,
  {
    removeShadowRoot,
  }: {
    removeShadowRoot: boolean;
  },
): void {
  clonedStyleElements.forEach((clones: HTMLStyleElement[]): void => {
    const clone: HTMLStyleElement | undefined = clones.find(
      (c: HTMLStyleElement): boolean => c.parentNode === linkedContainer,
    );
    if (clone) {
      clone.parentNode?.removeChild(clone);
      clones.splice(clones.indexOf(clone), 1);
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

/**
 * Tears down style scoping by disconnecting the observer and removing all styles
 * from registered containers.
 * This is useful for cleanup when the frontend application is unmounted.
 * You don't need to call removeStyledContainer for each container if you call this function.
 */
function tearDownStyleScoping({
  removeShadowRoot = false,
}: {
  removeShadowRoot?: boolean;
} = {}): void {
  styleObserver.disconnect();
  registeredContainers.forEach(
    (
      linkedContainer: HTMLElement | ShadowRoot,
      container: HTMLElement,
    ): void => {
      removeContainer(container, linkedContainer, { removeShadowRoot });
    },
  );
  clonedStyleElements.clear();
  pendingStyleUpdates.clear();
  hasScheduledStyleFlush = false;
  hoistedFontFaceRules.clear();
  hoistedStyleElements.forEach((styleElement: HTMLStyleElement): void => {
    styleElement.parentNode?.removeChild(styleElement);
  });
  hoistedStyleElements.clear();
}

/**
 * Creates a stylesheet from the given CSS text
 *
 * @param cssText - The CSS text to create a stylesheet from
 * @returns The created stylesheet or null if creation failed
 */
function getSheetFromStyleElement(
  styleElement: HTMLStyleElement,
): CSSStyleSheet | null {
  const parsingStyleElement = styleElement.cloneNode(true) as HTMLStyleElement;

  document.head.appendChild(parsingStyleElement);
  const { sheet } = parsingStyleElement;
  document.head.removeChild(parsingStyleElement);

  return sheet instanceof CSSStyleSheet ? sheet : null;
}

/**
 * Moves @font-face rules from Shadow DOM to global scope for font accessibility
 *
 * This is necessary because @font-face rules defined within Shadow DOM are not accessible
 * to elements inside the shadow boundary. By moving these rules to the document head,
 * fonts become available to all Shadow DOM containers
 *
 * See https://stackoverflow.com/questions/63710162/how-to-load-font-face-in-dynamically-loaded-styles-of-web-component-with-shadow
 *
 * @param styleSheet - The source stylesheet to extract font rules from
 */
function hoistFontFaceRules(styleElement: HTMLStyleElement): void {
  const styleSheet: CSSStyleSheet | null =
    getSheetFromStyleElement(styleElement);
  if (!styleSheet) {
    return;
  }

  const fontFaceRules: string[] = Array.from(styleSheet.cssRules ?? [])
    .filter(
      (rule: CSSRule): boolean =>
        rule.constructor.name === 'CSSFontFaceRule' &&
        !hoistedFontFaceRules.has(rule.cssText),
    )
    .map((rule: CSSRule): string => {
      hoistedFontFaceRules.add(rule.cssText);
      return rule.cssText;
    });

  if (fontFaceRules.length === 0) {
    return;
  }

  const hoistedStyleElement: HTMLStyleElement = document.createElement('style');
  hoistedStyleElement.textContent = fontFaceRules.join('\n');
  hoistedStyleElements.add(hoistedStyleElement);
  document.head.appendChild(hoistedStyleElement);
}

/**
 * Fixes style scoping
 * This replaces `:root` with `:host` to ensure styles apply correctly
 * in the global scope, especially for Shadow DOM styles
 *
 * @param textContent - The text content to fix root styles
 */
function fixRootScopingInTextContent(textContent = ''): string {
  return textContent.replace(
    /(^|[^a-zA-Z0-9_-]):root(?![a-zA-Z0-9_-])/g,
    '$1:host',
  );
}

export default registerStyleElement;
export { createStyledContainer, removeStyledContainer, tearDownStyleScoping };

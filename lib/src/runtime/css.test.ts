import {
  describe,
  it,
  expect,
  beforeEach,
  afterEach,
  rstest,
} from '@rstest/core';
import {
  registerModuleCss,
  unregisterModuleCss,
  createStyledContainer,
  removeStyledContainer,
  tearDownStyleScoping,
} from './css';

describe('styleScope', () => {
  // Constants
  const REGULAR_STYLE_CONTENT = '.test { color: red; }';
  const UPDATED_STYLE_CONTENT = '.test { color: blue; }';
  const FONT_FACE_STYLE_CONTENT =
    '@font-face { font-family: "TestFont"; src: url("test-font.woff"); }';
  const FONT_FACE_DUPLICATE_STYLE_CONTENT =
    '@font-face { font-family: "TestFontDuplicate"; src: url("test-font-duplicate.woff"); }';
  const ROOT_STYLE_CONTENT = ':root { color: red; }';
  const FIXED_ROOT_STYLE_CONTENT = ':host { color: red; }';
  const UPDATED_ROOT_STYLE_CONTENT = ':root { color: blue; }';
  const FIXED_UPDATED_ROOT_STYLE_CONTENT = ':host { color: blue; }';
  const ROOT_SUFFIX_STYLE_CONTENT = '.root:rooted { color: green; }';

  // Fixtures
  let container: HTMLElement;

  const getStylesWithContent = (content: string): HTMLStyleElement[] => {
    return Array.from(document.head.querySelectorAll('style')).filter((style) =>
      style.textContent?.includes(content),
    );
  };

  beforeEach(() => {
    rstest.clearAllMocks();

    container = document.createElement('div');
    document.body.appendChild(container);
  });

  afterEach(() => {
    document.body.innerHTML = '';
    tearDownStyleScoping();
  });

  describe('createStyledContainer', () => {
    it('does not reset container styles when not creating shadow root', () => {
      container.style.color = 'red';

      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      expect(container.shadowRoot).toBeNull();
      expect(container.style.color).toBe('red');
      expect(shadowRoot).toBeInstanceOf(HTMLElement);
    });

    it('does not reset container styles when creating shadow root', () => {
      container.style.color = 'red';

      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(container.shadowRoot).toBeInstanceOf(ShadowRoot);
      expect(container.style.color).toBe('red');
      expect(shadowRoot).toBeInstanceOf(ShadowRoot);
    });

    it('applies existing styles to container', () => {
      registerModuleCss('regular', REGULAR_STYLE_CONTENT);

      const innerContainer = createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      const styles = innerContainer.querySelectorAll('style');
      expect(styles.length).toBe(1);
      expect(styles[0]?.textContent?.includes(REGULAR_STYLE_CONTENT)).toBe(
        true,
      );
    });

    it('applies existing styles to shadow root', () => {
      registerModuleCss('regular', REGULAR_STYLE_CONTENT);

      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      const styles = shadowRoot.querySelectorAll('style');
      expect(styles.length).toBe(2);
      expect(styles[0]?.textContent).toBe(':host { all: initial; }');
      expect(styles[1]?.textContent?.includes(REGULAR_STYLE_CONTENT)).toBe(
        true,
      );
    });

    it('applies styles to new container', () => {
      const innerContainer = createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      registerModuleCss('regular', REGULAR_STYLE_CONTENT);

      const styles = innerContainer.querySelectorAll('style');
      expect(styles.length).toBe(1);
      expect(styles[0]?.textContent?.includes(REGULAR_STYLE_CONTENT)).toBe(
        true,
      );
    });

    it('applies styles to a new shadow root', () => {
      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      registerModuleCss('regular', REGULAR_STYLE_CONTENT);

      const styles = shadowRoot.querySelectorAll('style');
      expect(styles.length).toBe(2);
      expect(styles[0]?.textContent?.includes('all: initial')).toBe(true);
      expect(styles[1]?.textContent?.includes(REGULAR_STYLE_CONTENT)).toBe(
        true,
      );
    });

    it('does not register container multiple times', () => {
      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      const initialCount = container.querySelectorAll('style').length;

      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      expect(container.querySelectorAll('style').length).toBe(initialCount);
    });

    it('returns existing container if already registered', () => {
      const element = createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      const secondElement = createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      expect(secondElement).toBe(element);
      expect(element).toBeInstanceOf(HTMLElement);
    });

    it('returns a nested div container when returnNestedContainer is true', () => {
      const nestedContainer = createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: true,
      }) as HTMLDivElement;

      expect(nestedContainer).toBeInstanceOf(HTMLDivElement);
      expect(nestedContainer.parentElement).toBe(container);
      expect(nestedContainer.style.height).toBe('100%');
    });

    it('returns a nested div container inside shadow root when returnNestedContainer is true', () => {
      const nestedContainer = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: true,
      }) as HTMLDivElement;

      expect(nestedContainer).toBeInstanceOf(HTMLDivElement);
      expect(container.shadowRoot).toBeInstanceOf(ShadowRoot);
      expect(nestedContainer.getRootNode()).toBe(container.shadowRoot);
      expect(nestedContainer.style.height).toBe('100%');
    });

    it('returns existing inner container if already registered', () => {
      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      const secondShadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      const secondContainer = createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      expect(secondContainer).toBe(shadowRoot);
      expect(secondShadowRoot).toBe(shadowRoot);
      expect(shadowRoot).toBeInstanceOf(ShadowRoot);
    });
  });

  describe('removeStyledContainer', () => {
    it('clears styles and removes shadow root when removeShadowRoot is true', () => {
      const parent = document.createElement('div');
      parent.appendChild(container);

      createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(parent.children[0]?.shadowRoot).not.toBeNull();

      removeStyledContainer(container, { removeShadowRoot: true });

      expect(parent.children[0]?.shadowRoot).toBeNull();
      expect(container.shadowRoot?.children.length).toBe(0);
    });

    it('clears styles and keeps shadow root when removeShadowRoot is false', () => {
      const parent = document.createElement('div');
      parent.appendChild(container);

      createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(parent.children[0]?.shadowRoot).not.toBeNull();

      removeStyledContainer(container, { removeShadowRoot: false });

      expect(parent.children[0]?.shadowRoot).not.toBeNull();
      expect(parent.children[0]?.shadowRoot?.children.length).toBe(0);
    });

    it('keeps shadow root by default when passing shadow root', () => {
      const parent = document.createElement('div');
      parent.appendChild(container);

      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(parent.children[0]?.shadowRoot).not.toBeNull();

      removeStyledContainer(shadowRoot);

      expect(parent.children[0]?.shadowRoot).not.toBeNull();
      expect(parent.children[0]?.shadowRoot?.children.length).toBe(0);
    });

    it('removes shadow root when passing shadow root and removeShadowRoot is true', () => {
      const parent = document.createElement('div');
      parent.appendChild(container);

      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(parent.children[0]?.shadowRoot).not.toBeNull();

      removeStyledContainer(shadowRoot, { removeShadowRoot: true });

      expect(parent.children[0]?.shadowRoot).toBeNull();
      expect(container.shadowRoot?.children.length).toBe(0);
    });

    it('clears styles from container', () => {
      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      registerModuleCss('regular', REGULAR_STYLE_CONTENT);

      expect(container.querySelectorAll('style').length).toBeGreaterThan(0);

      removeStyledContainer(container);

      expect(container.querySelectorAll('style').length).toBe(0);
    });

    it('does not throw when removing unregistered container', () => {
      expect(() => removeStyledContainer(container)).not.toThrow();
    });

    it('does not remove styles from other containers', () => {
      const anotherContainer = document.createElement('div');

      registerModuleCss('regular', REGULAR_STYLE_CONTENT);

      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });
      createStyledContainer(anotherContainer, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      removeStyledContainer(container);

      expect(anotherContainer.querySelectorAll('style').length).toBeGreaterThan(
        0,
      );
    });

    it('removes all styles from the container', () => {
      const innerContainer = createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      expect(innerContainer.querySelectorAll('style').length).toBe(0);

      registerModuleCss('regular', REGULAR_STYLE_CONTENT);
      registerModuleCss('updated', UPDATED_STYLE_CONTENT);

      expect(innerContainer.querySelectorAll('style').length).toBe(2);

      removeStyledContainer(innerContainer);

      expect(innerContainer.querySelectorAll('style').length).toBe(0);
    });

    it('removes all styles from the shadow root', () => {
      const innerContainer = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(innerContainer.querySelectorAll('style').length).toBe(1);

      registerModuleCss('regular', REGULAR_STYLE_CONTENT);
      registerModuleCss('updated', UPDATED_STYLE_CONTENT);

      expect(innerContainer.querySelectorAll('style').length).toBe(3);

      removeStyledContainer(innerContainer);

      expect(innerContainer.querySelectorAll('style').length).toBe(0);
    });
  });

  describe('tearDownStyleScoping', () => {
    it('removes styles from all registered containers', () => {
      const anotherContainer = document.createElement('div');
      document.body.appendChild(anotherContainer);

      registerModuleCss('regular', REGULAR_STYLE_CONTENT);

      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });
      const shadowRoot = createStyledContainer(anotherContainer, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(container.querySelectorAll('style')).toHaveLength(1);
      expect(shadowRoot.querySelectorAll('style')).toHaveLength(2);

      tearDownStyleScoping();

      expect(container.querySelectorAll('style')).toHaveLength(0);
      expect(shadowRoot.querySelectorAll('style')).toHaveLength(0);
    });

    it('removes hoisted font-face global styles from document head', () => {
      for (let i = 0; i < 5; i++) {
        registerModuleCss('font', FONT_FACE_STYLE_CONTENT);

        expect(getStylesWithContent('TestFont')).toHaveLength(1);

        tearDownStyleScoping();

        expect(getStylesWithContent('TestFont')).toHaveLength(0);
      }
    });

    it('clears internal state so new registrations start fresh after teardown', () => {
      registerModuleCss('regular', REGULAR_STYLE_CONTENT);
      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      expect(container.querySelectorAll('style')).toHaveLength(1);

      tearDownStyleScoping();

      const freshContainer = document.createElement('div');
      document.body.appendChild(freshContainer);

      const linkedContainer = createStyledContainer(freshContainer, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });
      registerModuleCss('updated', UPDATED_STYLE_CONTENT);

      expect(linkedContainer.querySelectorAll('style')).toHaveLength(1);
      expect(linkedContainer.querySelectorAll('style')[0]?.textContent).toBe(
        UPDATED_STYLE_CONTENT,
      );
    });

    it('keeps shadow root by default on teardown', () => {
      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });
      expect(shadowRoot.querySelectorAll('style')).toHaveLength(1);

      tearDownStyleScoping();

      expect(container.shadowRoot).not.toBeNull();
      expect(container.shadowRoot?.querySelectorAll('style')).toHaveLength(0);
    });

    it('removes shadow root when requested on teardown', () => {
      const parent = document.createElement('div');
      parent.appendChild(container);

      createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      tearDownStyleScoping({ removeShadowRoot: true });

      expect(parent.children[0]?.shadowRoot).toBeNull();
    });
  });

  describe('registerModuleCss', () => {
    it('registers CSS text for a module', () => {
      expect(() =>
        registerModuleCss('regular', REGULAR_STYLE_CONTENT),
      ).not.toThrow();
    });

    it('moves font-face rules to document head', () => {
      registerModuleCss('font', FONT_FACE_STYLE_CONTENT);

      const fontStyles = getStylesWithContent('TestFont');
      expect(fontStyles.length).toBeGreaterThan(0);
    });

    it('prevents duplicate font-face rules', () => {
      registerModuleCss('font-1', FONT_FACE_DUPLICATE_STYLE_CONTENT);
      registerModuleCss('font-2', FONT_FACE_DUPLICATE_STYLE_CONTENT);

      expect(getStylesWithContent('TestFontDuplicate')).toHaveLength(1);
    });

    it('does not move regular CSS rules to document head', () => {
      const initialCount = document.head.querySelectorAll('style').length;

      registerModuleCss('regular', REGULAR_STYLE_CONTENT);

      expect(document.head.querySelectorAll('style')).toHaveLength(
        initialCount,
      );
    });

    it('updates styles when a module is registered again', () => {
      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      registerModuleCss('regular', REGULAR_STYLE_CONTENT);

      expect(container.querySelectorAll('style').length).toBe(1);
      expect(container.querySelectorAll('style')[0]?.textContent).toBe(
        REGULAR_STYLE_CONTENT,
      );

      registerModuleCss('regular', UPDATED_STYLE_CONTENT);

      expect(container.querySelectorAll('style').length).toBe(1);
      expect(container.querySelectorAll('style')[0]?.textContent).toBe(
        UPDATED_STYLE_CONTENT,
      );
    });

    it('updates styles in shadow roots when a module is registered again', () => {
      registerModuleCss('root', ROOT_STYLE_CONTENT);

      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(shadowRoot.querySelectorAll('style').length).toBe(2);
      expect(shadowRoot.querySelectorAll('style')[1]?.textContent).toBe(
        FIXED_ROOT_STYLE_CONTENT,
      );

      registerModuleCss('root', UPDATED_ROOT_STYLE_CONTENT);

      expect(shadowRoot.querySelectorAll('style').length).toBe(2);
      expect(shadowRoot.querySelectorAll('style')[1]?.textContent).toBe(
        FIXED_UPDATED_ROOT_STYLE_CONTENT,
      );
    });

    it('does not update a different module when another module changes', () => {
      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      registerModuleCss('regular', REGULAR_STYLE_CONTENT);
      registerModuleCss('other', REGULAR_STYLE_CONTENT);

      expect(container.querySelectorAll('style').length).toBe(2);
      expect(container.querySelectorAll('style')[0]?.textContent).toBe(
        REGULAR_STYLE_CONTENT,
      );

      registerModuleCss('other', UPDATED_STYLE_CONTENT);

      expect(container.querySelectorAll('style').length).toBe(2);
      expect(container.querySelectorAll('style')[0]?.textContent).toBe(
        REGULAR_STYLE_CONTENT,
      );
    });

    it('unregisters a module from all containers', () => {
      const anotherContainer = document.createElement('div');
      document.body.appendChild(anotherContainer);

      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });
      const anotherLinkedContainer = createStyledContainer(anotherContainer, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });
      registerModuleCss('regular', REGULAR_STYLE_CONTENT);
      registerModuleCss('other', UPDATED_STYLE_CONTENT);

      expect(container.querySelectorAll('style')).toHaveLength(2);
      expect(anotherLinkedContainer.querySelectorAll('style')).toHaveLength(3);

      unregisterModuleCss('regular');

      expect(container.querySelectorAll('style')).toHaveLength(1);
      expect(anotherLinkedContainer.querySelectorAll('style')).toHaveLength(2);
      expect(
        anotherLinkedContainer.querySelector('style:last-child')?.textContent,
      ).toBe(UPDATED_STYLE_CONTENT);
    });

    it('does not throw when unregistering an unknown module', () => {
      expect(() => unregisterModuleCss('unknown')).not.toThrow();
    });

    it('removes a module font-face rule when it is unregistered', () => {
      registerModuleCss('font', FONT_FACE_STYLE_CONTENT);
      expect(getStylesWithContent('TestFont')).toHaveLength(1);

      unregisterModuleCss('font');

      expect(getStylesWithContent('TestFont')).toHaveLength(0);
    });

    it('handles root styles depending on the container', () => {
      registerModuleCss('root', ROOT_STYLE_CONTENT);

      const container1 = createStyledContainer(document.createElement('div'), {
        createShadowRoot: true,
        returnNestedContainer: false,
      });
      const container2 = createStyledContainer(document.createElement('div'), {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      const shadowRootStyles = container1.querySelectorAll('style')[1];
      expect(shadowRootStyles?.textContent).toBe(FIXED_ROOT_STYLE_CONTENT);

      const regularStyles = container2.querySelectorAll('style')[0];
      expect(regularStyles?.textContent).toBe(ROOT_STYLE_CONTENT);
    });

    it('does not replace root-like tokens that are not the :root selector', () => {
      registerModuleCss('root-suffix', ROOT_SUFFIX_STYLE_CONTENT);

      const shadowRoot = createStyledContainer(document.createElement('div'), {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      const shadowRootStyles = shadowRoot.querySelectorAll('style')[1];
      expect(shadowRootStyles?.textContent).toBe(ROOT_SUFFIX_STYLE_CONTENT);
    });
  });
});

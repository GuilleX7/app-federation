import {
  describe,
  it,
  expect,
  beforeEach,
  afterEach,
  rstest,
} from '@rstest/core';
import registerStyleElement, {
  createStyledContainer,
  removeStyledContainer,
  tearDownStyleScoping,
} from './index';

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

  // Helpers
  const createStyle = (content: string): HTMLStyleElement => {
    const style = document.createElement('style');
    style.textContent = content;

    return style;
  };

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
      registerStyleElement(createStyle(REGULAR_STYLE_CONTENT));

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
      registerStyleElement(createStyle(REGULAR_STYLE_CONTENT));

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

      registerStyleElement(createStyle(REGULAR_STYLE_CONTENT));

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

      registerStyleElement(createStyle(REGULAR_STYLE_CONTENT));

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
      });

      expect(nestedContainer).toBeInstanceOf(HTMLDivElement);
      expect(nestedContainer.parentElement).toBe(container);
      expect(nestedContainer.style.height).toBe('100%');
    });

    it('returns a nested div container inside shadow root when returnNestedContainer is true', () => {
      const nestedContainer = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: true,
      });

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

      expect(parent.children[0].shadowRoot).not.toBeNull();

      removeStyledContainer(container, { removeShadowRoot: true });

      expect(parent.children[0].shadowRoot).toBeNull();
      expect(container.shadowRoot?.children.length).toBe(0);
    });

    it('clears styles and keeps shadow root when removeShadowRoot is false', () => {
      const parent = document.createElement('div');
      parent.appendChild(container);

      createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(parent.children[0].shadowRoot).not.toBeNull();

      removeStyledContainer(container, { removeShadowRoot: false });

      expect(parent.children[0].shadowRoot).not.toBeNull();
      expect(parent.children[0].shadowRoot?.children.length).toBe(0);
    });

    it('keeps shadow root by default when passing shadow root', () => {
      const parent = document.createElement('div');
      parent.appendChild(container);

      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(parent.children[0].shadowRoot).not.toBeNull();

      removeStyledContainer(shadowRoot);

      expect(parent.children[0].shadowRoot).not.toBeNull();
      expect(parent.children[0].shadowRoot?.children.length).toBe(0);
    });

    it('removes shadow root when passing shadow root and removeShadowRoot is true', () => {
      const parent = document.createElement('div');
      parent.appendChild(container);

      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(parent.children[0].shadowRoot).not.toBeNull();

      removeStyledContainer(shadowRoot, { removeShadowRoot: true });

      expect(parent.children[0].shadowRoot).toBeNull();
      expect(container.shadowRoot?.children.length).toBe(0);
    });

    it('clears styles from container', () => {
      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      registerStyleElement(createStyle(REGULAR_STYLE_CONTENT));

      expect(container.querySelectorAll('style').length).toBeGreaterThan(0);

      removeStyledContainer(container);

      expect(container.querySelectorAll('style').length).toBe(0);
    });

    it('does not throw when removing unregistered container', () => {
      expect(() => removeStyledContainer(container)).not.toThrow();
    });

    it('does not remove styles from other containers', () => {
      const anotherContainer = document.createElement('div');

      registerStyleElement(createStyle(REGULAR_STYLE_CONTENT));

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
      const style1 = createStyle(REGULAR_STYLE_CONTENT);
      const style2 = createStyle(UPDATED_STYLE_CONTENT);

      const innerContainer = createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      expect(innerContainer.querySelectorAll('style').length).toBe(0);

      registerStyleElement(style1);
      registerStyleElement(style2);

      expect(innerContainer.querySelectorAll('style').length).toBe(2);

      removeStyledContainer(innerContainer);

      expect(innerContainer.querySelectorAll('style').length).toBe(0);
    });

    it('removes all styles from the shadow root', () => {
      const style1 = createStyle(REGULAR_STYLE_CONTENT);
      const style2 = createStyle(UPDATED_STYLE_CONTENT);

      const innerContainer = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(innerContainer.querySelectorAll('style').length).toBe(1);

      registerStyleElement(style1);
      registerStyleElement(style2);

      expect(innerContainer.querySelectorAll('style').length).toBe(3);

      removeStyledContainer(innerContainer);

      expect(innerContainer.querySelectorAll('style').length).toBe(0);
    });
  });

  describe('tearDownStyleScoping', () => {
    it('removes styles from all registered containers', () => {
      const anotherContainer = document.createElement('div');
      document.body.appendChild(anotherContainer);

      registerStyleElement(createStyle(REGULAR_STYLE_CONTENT));

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
        registerStyleElement(createStyle(FONT_FACE_STYLE_CONTENT));

        expect(getStylesWithContent('TestFont')).toHaveLength(1);

        tearDownStyleScoping();

        expect(getStylesWithContent('TestFont')).toHaveLength(0);
      }
    });

    it('clears internal state so new registrations start fresh after teardown', () => {
      registerStyleElement(createStyle(REGULAR_STYLE_CONTENT));
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
      registerStyleElement(createStyle(UPDATED_STYLE_CONTENT));

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

  describe('registerStyleElement', () => {
    it('processes valid HTMLStyleElement', () => {
      expect(() =>
        registerStyleElement(createStyle(REGULAR_STYLE_CONTENT)),
      ).not.toThrow();
    });

    it('ignores non-HTMLStyleElement', () => {
      expect(() =>
        registerStyleElement(
          document.createElement('div') as unknown as HTMLStyleElement,
        ),
      ).not.toThrow();
    });

    it('moves font-face rules to document head', () => {
      registerStyleElement(createStyle(FONT_FACE_STYLE_CONTENT));

      const fontStyles = getStylesWithContent('TestFont');
      expect(fontStyles.length).toBeGreaterThan(0);
    });

    it('prevents duplicate font-face rules', () => {
      registerStyleElement(createStyle(FONT_FACE_DUPLICATE_STYLE_CONTENT));
      registerStyleElement(createStyle(FONT_FACE_DUPLICATE_STYLE_CONTENT));

      expect(getStylesWithContent('TestFontDuplicate')).toHaveLength(1);
    });

    it('does not move regular CSS rules to document head', () => {
      const initialCount = document.head.querySelectorAll('style').length;

      registerStyleElement(createStyle(REGULAR_STYLE_CONTENT));

      expect(document.head.querySelectorAll('style')).toHaveLength(
        initialCount,
      );
    });

    it('maintains consistency when registered style changes', async () => {
      const style = createStyle(REGULAR_STYLE_CONTENT);
      registerStyleElement(style);

      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      expect(container.querySelectorAll('style').length).toBe(1);
      expect(container.querySelectorAll('style')[0]?.textContent).toBe(
        REGULAR_STYLE_CONTENT,
      );

      style.textContent = UPDATED_STYLE_CONTENT;
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(container.querySelectorAll('style').length).toBe(1);
      expect(container.querySelectorAll('style')[0]?.textContent).toBe(
        UPDATED_STYLE_CONTENT,
      );
    });

    it('syncs style attributes when registered style changes', async () => {
      const style = createStyle(REGULAR_STYLE_CONTENT);
      registerStyleElement(style);

      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });
      const clone = container.querySelectorAll('style')[0];

      expect(clone?.getAttribute('media')).toBeNull();

      style.setAttribute('media', 'screen');
      style.setAttribute('title', 'test-title');
      style.setAttribute('random-property', 'test-prop');
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(clone?.getAttribute('media')).toBe('screen');
      expect(clone?.getAttribute('title')).toBe('test-title');
      expect(clone?.getAttribute('random-property')).toBe('test-prop');

      style.removeAttribute('random-property');
      style.setAttribute('random-property-2', 'test-prop-2');
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(clone?.getAttribute('random-property')).toBeNull();
      expect(clone?.getAttribute('random-property-2')).toBe('test-prop-2');
    });

    it('maintains consistency when registered style changes in shadow root', async () => {
      const style = createStyle(ROOT_STYLE_CONTENT);
      registerStyleElement(style);

      const shadowRoot = createStyledContainer(container, {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      expect(shadowRoot.querySelectorAll('style').length).toBe(2);
      expect(shadowRoot.querySelectorAll('style')[1]?.textContent).toBe(
        FIXED_ROOT_STYLE_CONTENT,
      );

      style.textContent = UPDATED_ROOT_STYLE_CONTENT;
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(shadowRoot.querySelectorAll('style').length).toBe(2);
      expect(shadowRoot.querySelectorAll('style')[1]?.textContent).toBe(
        FIXED_UPDATED_ROOT_STYLE_CONTENT,
      );
    });

    it('ignores changes to unregistered styles', () => {
      const registeredStyle = createStyle(REGULAR_STYLE_CONTENT);
      const unregisteredStyle = createStyle(REGULAR_STYLE_CONTENT);

      registerStyleElement(registeredStyle);
      createStyledContainer(container, {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      expect(container.querySelectorAll('style').length).toBe(1);
      expect(container.querySelectorAll('style')[0]?.textContent).toBe(
        REGULAR_STYLE_CONTENT,
      );

      unregisteredStyle.textContent = UPDATED_STYLE_CONTENT;

      expect(container.querySelectorAll('style').length).toBe(1);
      expect(container.querySelectorAll('style')[0]?.textContent).toBe(
        REGULAR_STYLE_CONTENT,
      );
    });

    it('handles root styles depending on the container', () => {
      const style = createStyle(ROOT_STYLE_CONTENT);

      registerStyleElement(style);

      const container1 = createStyledContainer(document.createElement('div'), {
        createShadowRoot: true,
        returnNestedContainer: false,
      });
      const container2 = createStyledContainer(document.createElement('div'), {
        createShadowRoot: false,
        returnNestedContainer: false,
      });

      const shadowRootStyles = container1.querySelectorAll('style')[1];
      expect(shadowRootStyles.textContent).toBe(FIXED_ROOT_STYLE_CONTENT);

      const regularStyles = container2.querySelectorAll('style')[0];
      expect(regularStyles.textContent).toBe(ROOT_STYLE_CONTENT);
    });

    it('does not replace root-like tokens that are not the :root selector', () => {
      const style = createStyle(ROOT_SUFFIX_STYLE_CONTENT);
      registerStyleElement(style);

      const shadowRoot = createStyledContainer(document.createElement('div'), {
        createShadowRoot: true,
        returnNestedContainer: false,
      });

      const shadowRootStyles = shadowRoot.querySelectorAll('style')[1];
      expect(shadowRootStyles?.textContent).toBe(ROOT_SUFFIX_STYLE_CONTENT);
    });
  });
});

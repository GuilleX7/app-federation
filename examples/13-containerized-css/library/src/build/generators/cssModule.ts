import path from "path";

export class CssModuleGenerator {
  private internalCounter = 0;
  private modulePathToId = new Map<string, string>();

  public getModuleName(modulePath: string) {
    if (!this.modulePathToId.has(modulePath)) {
      this.modulePathToId.set(modulePath, `css-${this.internalCounter++}.js`);
    }

    return this.modulePathToId.get(modulePath)!;
  }

  public getModuleCode(modulePath: string) {
    const originalRequestString = JSON.stringify(modulePath + "?original");
    const cssRuntimeRequestString = JSON.stringify(
      path.join(import.meta.dirname, "..", "runtime", "css.js"),
    );

    return `
import cssText from ${originalRequestString};
import { registerModuleCss } from ${cssRuntimeRequestString};
registerModuleCss(__webpack_module__.id, cssText);
export default cssText;
export * from ${originalRequestString};
`;
  }
}

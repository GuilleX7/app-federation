import path from "path";
import { mkdirSync, unlinkSync, writeFileSync } from "fs";

export class TempFS {
  private filePaths: string[] = [];

  constructor(private folderPath: string) {}

  public initialize(): void {
    try {
      mkdirSync(this.folderPath, { recursive: true });
    } catch (error) {
      console.error("Failed to create temp folder:", error);
    }
  }

  public getRootPath(): string {
    return this.folderPath;
  }

  public getPath(fileName: string): string {
    return path.join(this.getRootPath(), fileName);
  }

  public write(fileName: string, content: string): void {
    const filePath = this.getPath(fileName);
    try {
      mkdirSync(path.dirname(filePath), { recursive: true });
      writeFileSync(filePath, content);
      this.filePaths.push(filePath);
    } catch (error) {
      console.error("Failed to write file:", error);
    }
  }

  public cleanup(): void {
    this.filePaths.forEach((filePath) => {
      try {
        unlinkSync(filePath);
      } catch (error) {
        console.error("Failed to clean-up file:", error);
      }
    });
    this.filePaths = [];
  }
}

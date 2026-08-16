declare module "*.css" {
  const classes: Record<string, string>;
  const content: string;
  export = classes;
  export default content;
}

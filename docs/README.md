# Project documentation

The report in this directory is authored in Typst. [`main.typ`](main.typ) is the document entry point: it applies the global theme and includes the front matter, numbered chapters, and bibliography in order.

## Structure

- `sections/` contains the document content. Numeric prefixes keep the files in reading order: front page, abstract, acknowledgements and outline (`0000`-`0003`); introduction (`0100`); project plan (`0200`); project analysis (`0300`); research and development (`0400`); user guide (`0500`); conclusions (`0600`); and bibliography (`9999`). The research chapter includes `0410`-`0440` on bundlers, dynamic loading, style injection, and communication.
- `themes/` defines shared document styling and the separate preface, main-content, and postface layouts.
- `figures/` contains diagrams and images referenced by the chapters.
- `fonts/` contains EB Garamond font files included with the project.
- `citations.bib` is the bibliography database.
- `utils.typ` and `utils/` contain shared layout helpers, units, and terminology helpers.

Keep included files and assets at their existing relative paths, since `main.typ` and the section files import them by path.

## Compile to PDF

Install the Typst CLI, then run the compiler from this directory:

```sh
typst compile main.typ app-federation.pdf
```

This writes `app-federation.pdf` into `docs/`. To recompile automatically when a source file changes, use watch mode:

```sh
typst watch main.typ app-federation.pdf
```

The themes and utilities import the `codly`, `codly-languages`, and `zero` preview packages. Typst resolves these imports during compilation; the first compile may need network access to fetch packages that are not already cached.

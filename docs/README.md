# Project documentation

The report in this directory is authored in Typst. [`main.typ`](main.typ) is the document entry point, it applies the global theme and includes the front matter, numbered chapters, and bibliography in order.

## Compile to PDF

Install the Typst CLI, then run the compiler from this directory:

```sh
typst compile --root .. main.typ app-federation.pdf
```

This writes `main.pdf` into `docs/`. To recompile automatically when the source changes, use watch mode:

```sh
typst watch main.typ
```

The document imports `codly`, `codly-languages`, and `zero` packages from Typst Universe, which Typst resolves automatically during compilation. The first compile may need network access to fetch packages that are not already cached.

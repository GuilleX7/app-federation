# App Federation

App Federation is a TypeScript prototype for integrating independently built browser applications as microfrontends. A host loads a remote entry by URL, mounts the remote into a DOM container, and later calls its unmount lifecycle. The library also provides helpers for typed communication and CSS scoping.

## Repository layout

- [`docs/`](docs/README.md) contains the project report, written in Typst, along with its sections, themes, figures, fonts, bibliography, and utilities.
- [`examples/`](examples/) contains numbered projects that demonstrate the implementation in stages. The current library package is in `lib`; some later examples keep local library snapshots to show the version used at that stage.
- [`lib/src/`](lib/src/) contains the maintained library source. Run the library build to generate [`lib/dist/`](lib/dist/), the compiled JavaScript and TypeScript declarations.
- [`lib/README.md`](lib/README.md) explains the package API and how to use it.

## Get started

Install the repository's npm workspace dependencies from the root:

```sh
npm install
```

Build the maintained library:

```sh
npm run build-lib
```

Build the library and all numbered examples (01-16):

```sh
npm run build
```

Several multi-application examples also have development scripts. For example, to run example 16, which demonstrates a shared event bus:

```sh
npm run dev-example-16
```

The root [`package.json`](package.json) lists the available build and development scripts.

## Example progression

The numbered examples build on one another:

| Examples | Focus |
| --- | --- |
| `01`-`04` | Bundling, modules, and chunks |
| `05`-`09` | Initial host/remote integration, entry loading, caching, runtime factories, and multiple entries |
| `10`-`11` | Containerization and public path handling |
| `12`-`14` | Build plugin integration and CSS injection or scoping |
| `15`-`16` | Typed props and actions, then event-bus communication |

[`examples/experimental/`](examples/experimental/) contains exploratory projects and is not part of the root `npm run build` command.

## Documentation

See [`docs/README.md`](docs/README.md) for the Typst document structure and compile commands. The report's entry file is `docs/main.typ`.

## License

This project is distributed under the MIT License. See [`LICENSE`](LICENSE).

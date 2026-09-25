#let italicWords = (
  "bundle",
  "bundles",
  "bundler",
  "bundlers",
  "microfrontend",
  "microfrontends",
  "scripting",
  "run-time",
  "runtime",
  "build-time",
  "byte",
  "true",
  "false",
  "dead code",
  "tree shaking",
  "side-effects",
  "reflection",
  "import",
  "imports",
  "require",
  "entrypoint",
  "code splitting",
  "chunk",
  "chunks",
  "window",
  "chunkloader",
  "script",
  "scripts",
)

#let word(word) = "[ \(]" + word + "[ ,.\):]"
#let words(words) = word("(" + words.join("|") + ")")

#let specialWords(content) = {
  show regex(words(italicWords)): it => it.text.slice(0, 1) + emph(it.text.slice(1, -1)) + it.text.slice(-1)

  content
}

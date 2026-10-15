#let italicWords = (
  "bundler",
  "bundlers",
  "bundle",
  "bundles",
  "scripting",
  "byte",
  "bytes",
  "chunk",
  "chunks",
  "script",
  "scripts",
  "microfrontend",
  "microfrontends",
  "shadow root",
  "shadow roots",
  "CSS Modules",
  "Just Enough Design Up Front",
  "Asynchronous Module Definition",
  "JSON with Padding",
)

#let word(word) = "[ \(]" + word + "[ ,.;:!?\):]"
#let words(words) = word("(" + words.join("|") + ")")

#let specialWords(content) = {
  show regex(words(italicWords)): it => it.text.slice(0, 1) + emph(it.text.slice(1, -1)) + it.text.slice(-1)

  content
}

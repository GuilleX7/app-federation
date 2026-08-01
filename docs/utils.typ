#let regular = 12pt
#let large = 14pt
#let very-large = 17pt
#let very-very-large = 20pt
#let huge = 25pt
#let very-huge = 25pt

#let text_lines(text, from: 0, to: none) = {
  return text.split("\n").slice(from, to).join("\n")
}

#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": *
#import "../utils/constants.typ": *

#let codeBackgroundColor = rgb(245, 245, 245)

#let global-theme(content) = [
  #show: codly.lang-set_(languages: codly-languages)
  #show: codly.set_(
    breakable: true,
    smart-skip: true,
  )
  #show: codly.theme(
    "github-light",
    fill: codeBackgroundColor,
    header: (fill: codeBackgroundColor),
    lang: (fill: codeBackgroundColor, stroke: codeBackgroundColor),
    file: (fill: codeBackgroundColor, stroke: codeBackgroundColor),
  )

  #set text(lang: "es", size: 12pt, font: "New Computer Modern")

  #content
]
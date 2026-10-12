
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#import "../utils/constants.typ": *

#let global-theme(content) = [
  #show: codly-init
  #codly(
    languages: codly-languages,
    breakable: true,
    lang-format: none,
    fill: rgb(250, 250, 250),
    zebra-fill: none,
    stroke: none,
    smart-skip: true,
  )

  #set text(lang: "es", size: 12pt, font: "New Computer Modern")

  #content
]

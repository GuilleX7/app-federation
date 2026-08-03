#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#import "../utils.typ": *

#let global-theme(content) = [
  #show: codly-init
  #codly(
    languages: codly-languages,
    breakable: true,
    lang-format: none,
    fill: rgb(250, 250, 250),
    zebra-fill: none,
    stroke: none,
  )

  #set text(size: 12pt, font: "New Computer Modern")

  #show figure.where(kind: raw): set figure(supplement: "Code")

  #content
]

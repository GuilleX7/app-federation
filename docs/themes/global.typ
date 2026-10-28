#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": *
#import "../utils/constants.typ": *

#let codeBackgroundColor = rgb(250, 250, 250)
#let tagBackgroundColor = rgb(245, 245, 245)

#let global-theme(content) = [
  #show: codly.lang-set_(languages: codly-languages)
  #show: codly.set_(
    breakable: true,
    smart-skip: true,
  )
  #show: codly.theme(
    "github-light",
    fill: codeBackgroundColor,
    header: (fill: tagBackgroundColor, repeat: true),
    lang: (fill: tagBackgroundColor, stroke: tagBackgroundColor, display-name: false, display-icon: true),
    file: (fill: tagBackgroundColor, stroke: tagBackgroundColor),
  )

  #content
]
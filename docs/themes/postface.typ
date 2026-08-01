#import "../utils.typ": *

#let postface-theme(content) = [
  #set page(
    numbering: "1",
    margin: 2.5cm,
    footer: context [
      #set align(center)
      #set text(size: regular)
      #counter(page).display()
    ],
  )

  #set par(
    first-line-indent: (amount: 0.75cm, all: true),
    justify: true,
  )

  #show heading.where(level: 1): it => [
    #[
      #set page(footer: none)
      #pagebreak(to: "odd")
    ]

    #set text(size: huge)
    #pad(left: 0.75cm)[#smallcaps[#it]]
    #block(
      fill: black,
      width: 100%,
      height: 1.5pt,
      above: 0.45cm,
      below: 1cm,
    )
  ]

  #content
]

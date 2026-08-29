// LTeX: enabled=false

#import "../utils.typ": *

#let content-theme(content) = [
  #set page(
    numbering: "1",
    margin: (inside: 3.5cm, outside: 2.5cm, top: 2.5cm, bottom: 2.5cm),
    footer: context [
      #set align(center)
      #set text(size: regular)
      #counter(page).display()
    ],
    header: context [
      #let pages-with-headings = query(selector(heading.where(level: 1))).map(it => it.location().page())

      #if not pages-with-headings.contains(here().page()) [
        #set align(if calc.rem(here().page(), 2) == 0 { left } else { right })
        #set text(size: regular)
        #let current-heading = query(selector(heading.where(level: 1).before(here()))).last()

        #pad[
          *Capítulo #counter(heading).get().first(). #current-heading.body.text*
        ]
        #block(above: 4pt, fill: black, width: 100%, height: 0.5pt)
      ]
    ],
  )

  #set heading(numbering: (..nums) => {
    let pos = nums.pos().map(str)
    if pos.len() == 1 {
      return pos.join(".")
    } else {
      return pos.join(".") + "."
    }
  })

  #set par(
    first-line-indent: (amount: 0.8cm, all: true),
    justify: true,
    spacing: 1.5em,
  )

  #set list(indent: 0.75cm, spacing: 1.5em, marker: scale(50%)[#sym.square.filled.tiny])
  #set enum(indent: 0.45cm, spacing: 0.5em)

  #set figure(numbering: it => numbering("1.1", counter(heading).get().at(0), it))
  #set math.equation(numbering: it => numbering("(1.1)", counter(heading).get().at(0), it))

  #show figure.where(kind: table): set figure(supplement: "Tabla")
  #show figure.where(kind: raw): set figure(supplement: "Código")
  #show figure.where(kind: image): set figure(supplement: "Ilustración")
  #show figure.where(kind: math.equation): set figure(supplement: "Ecuación")

  #show figure: it => [
    #v(0.3cm)
    #it
  ]

  #show figure.caption: it => context [
    #v(0.15cm)
    *#it.supplement #it.counter.display()#it.separator*#it.body
    #v(0.3cm)
  ]

  #show heading.where(level: 1): it => [
    #[
      #set page(footer: none, header: none)
      #pagebreak(to: "odd")
    ]

    #set text(size: huge)
    #set par(first-line-indent: 0pt, justify: false)
    #v(3cm)
    #box(width: 1.5cm)[#counter(heading).display()]
    #smallcaps[#it.body]

    #block(
      fill: black,
      width: 100%,
      height: 1pt,
      above: 0.45cm,
      below: 1cm,
    )
  ]


  #show heading.where(level: 2): it => {
    set text(size: very-large)
    block(above: 0.8cm, below: 0.8cm)[
      #counter(heading).display();
      #h(0.5em)
      #it.body
    ]
  }

  #show heading.where(level: 3): it => {
    set text(size: large)
    block(above: 0.6cm, below: 0.6cm)[
      #counter(heading).display();
      #h(0.5em)
      #it.body
    ]
  }

  #counter(page).update(1)

  #content
]

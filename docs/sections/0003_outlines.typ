#import "../utils.typ": *

#set heading(outlined: false, bookmarked: true)

#show outline.entry.where(level: 1): it => {
  set text(weight: "bold")
  block(above: 18pt)[#it]
}

#outline(title: "Índice")

#context {
  if counter(figure.where(kind: image)).final().any(n => n > 0) {
    outline(title: "Índice de ilustraciones", target: figure.where(kind: image))
  }

  if counter(figure.where(kind: table)).final().any(n => n > 0) {
    outline(title: "Índice de tablas", target: figure.where(kind: table))
  }

  if counter(figure.where(kind: raw)).final().any(n => n > 0) {
    outline(title: "Índice de código", target: figure.where(kind: raw))
  }

  if counter(figure.where(kind: math.equation)).final().any(n => n > 0) {
    outline(title: "Índice de ecuaciones", target: figure.where(kind: math.equation))
  }
}


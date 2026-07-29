#import "../variables.typ": *

#set heading(outlined: false, bookmarked: true)

#show outline.entry.where(level: 1): it => {
  set text(weight: "bold")
  block(above: 18pt)[#it]
}

#outline(title: "Table of contents")

#context {
  if counter(figure).final().any(n => n > 0) {
    outline(title: "List of figures", target: figure.where(kind: image))
  }

  if counter(table).final().any(n => n > 0) {
    outline(title: "List of tables", target: figure.where(kind: table))
  }

  if counter(raw).final().any(n => n > 0) {
    outline(title: "List of code snippets", target: figure.where(kind: raw))
  }


  if counter(math.equation).final().any(n => n > 0) {
    outline(title: "List of equations", target: figure.where(kind: math.equation))
  }
}


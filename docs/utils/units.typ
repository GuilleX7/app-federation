#import "@preview/zero:0.7.1": num, set-num, set-round, zi

#let eurUnit = zi.declare("€", alt: "euros")
#let eur = qty => {
  set-num(math: false, digits: 2)
  set-round(precision: 2)
  eurUnit(qty)
}

#import "@preview/zero:0.7.1": num

#let eur = qty => {
  box(num(qty, math: false, digits: 2) + " €")
}

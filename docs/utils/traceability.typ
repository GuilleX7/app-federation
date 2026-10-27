#let requirementTraceabilityTable(general, functional, nonFunctional, useCases) = figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    [Generales], [Funcionales], [No funcionales], [Casos de uso],
    general, functional, nonFunctional, useCases,
  ),
  caption: [Requisitos y casos de uso abordados],
)

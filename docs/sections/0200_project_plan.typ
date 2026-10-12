#import "../utils/units.typ": eur


= Planificación del proyecto <project-planning>

En este capítulo vamos a cubrir algunos aspectos formales del proyecto. Comenzaremos explicando la metodología usada a lo largo de la elaboración del trabajo. Después, detallaremos la planificación de tareas. Finalmente, realizaremos un análisis de costes, incluyendo el coste total del proyecto y las desviaciones.

== Metodología <methodology>
Como hemos explicado en en el @goals[capítulo], el resultado final de este trabajo abarca dos productos. Por un lado, este mismo documento debe funcionar no solo como documentación exhaustiva de la biblioteca, sino como una investigación que culmina con un tutorial que visita cada uno de los problemas y las soluciones propuestas, complementándose con proyectos de ejemplo que ilustran los mecanismos alcanzados.

Por otro lado, la biblioteca final es un producto software que requiere un diseño previo a su desarrollo, pero cuyos requisitos pueden ir variando según el resultado de la investigación realizada. Así, ambos productos están estrechamente relacionados, por lo que un cambio inesperado en cualquiera de ellos provoca el consiguiente cambio en el otro.

=== Just Enough Design Up Front

La idea de usar Just Enough Design Up Front (o JEDUF, de sus siglas en inglés) emerge de combinar la necesidad de tener un diseño detallado de alto nivel, pues conocemos con exactitud cómo deben comportarse los microfrontends, con la necesidad de utilizar ciclos de desarrollo ágiles, ya que la implementación cambiará según avance la investigación.

JEDUF es un enfoque que ajusta la cantidad de diseño inicial a las necesidades y el contexto del proyecto, en vez de exigir un diseño exhaustivo antes de empezar la implementación @cite-jeduf. En este trabajo se combina ese enfoque con ciclos iterativos e incrementales: se repite el proceso de investigación y desarrollo, y cada iteración incorpora funcionalidad al producto @cite-agile-alliance-incremental.

Esto se corresponde directamente con la dirección de este proyecto: aunque podemos considerar que el tutorial, la especificación técnica y la biblioteca prototipo alcanzarán eventualmente la definición de hecho, su propia naturaleza experimental impide que realicemos un diseño excesivamente detallado desde el inicio.

Así, este proyecto trata de definir una especificación técnica a través de la implementación de referencia que, teniendo en cuenta las posibilidades ofrecidas por la mayoría de bundlers de la actualidad, sea fácilmente implementable utilizando tecnologías diferentes a las usadas en este proyecto. Todos los conceptos técnicos que se usarán para el diseño se corresponderán con ideas abstractas relacionadas con los microfrontends o la web y no con tecnologías concretas.

=== Desarrollo iterativo e incremental

Aunque existen muchas metodologías para controlar el tiempo de desarrollo, la mayoría añade una complejidad excesiva para una investigación llevada a cabo por una única persona. Así, este proyecto usa una metodología ligera derivada del desarrollo iterativo e incremental @cite-agile-alliance-incremental. Algunos de los puntos más remarcables son:

- *Los ciclos iterativos no tienen una duración fija.* En su lugar, cada ciclo durará el tiempo necesario para realizar la investigación necesaria, implementar la funcionalidad en la biblioteca prototipo, crear un ejemplo de referencia, probarlo, eliminar la deuda técnica y documentarlo. No obstante, el uso de hitos se mantiene, pues resulta interesante para medir el progreso a lo largo del tiempo y conocer qué partes del proyecto consumieron más recursos.

- *La documentación debe mantenerse sincronizada con el producto.* Para evitar que la documentación quede desfasada con respecto al estado real de la biblioteca, este documento incrusta código fuente de los archivos de ejemplo sin alterarlos, asegurando que lo que se escribe puede trazarse a su fuente original. Al final de cada ciclo, el documento debe ser revisado para asegurar que el código incrustado se corresponde con la documentación proporcionada.

- *Un bloqueo persistente implica rediseño.* Cuando durante un ciclo iterativo se produce un bloque de duración excesiva; por ejemplo, si tras realizar una investigación se concluye que la implementación sería muy costosa, se debe poner el foco en rediseñar el producto para sortear el problema.

== Planificación de tareas <task-planning>

En esta sección listaremos las tareas que se han llevado a cabo a lo largo del proyecto, junto a su duración estimada, real y la desviación entre ambas de acuerdo a los datos obtenidos.

#let tasks = (
  (title: [Investigación soluciones \ existentes], estimatedDuration: 10, actualDuration: 8),
  (title: [Investigación inyección], estimatedDuration: 50, actualDuration: 48),
  (title: [Investigación estilos], estimatedDuration: 30, actualDuration: 36),
  (title: [Investigación comunicación], estimatedDuration: 10, actualDuration: 7),
  (title: [Desarrollo de ejemplos], estimatedDuration: 100, actualDuration: 120),
  (title: [Documentación final], estimatedDuration: 100, actualDuration: 110),
)
#let totalEstimatedDuration = tasks.map(t => t.estimatedDuration).sum()
#let totalActualDuration = tasks.map(t => t.actualDuration).sum()

#figure(
  [
    #show table.cell.where(y: tasks.len() + 1): set text(weight: "bold")
    #table(
      columns: 5,
      table.header([Nº], [Tarea], [Duración \ estimada], [Duración \ real], [Desviación]),
      ..tasks
        .enumerate(start: 1)
        .map(((i, a)) => (
          [#i],
          [#a.title],
          [#a.estimatedDuration h],
          [#a.actualDuration h],
          [#{ a.actualDuration - a.estimatedDuration } h],
        ))
        .flatten(),
      table.footer(
        [],
        [Total],
        [#{ totalEstimatedDuration } h],
        [#{ totalActualDuration } h],
        [#{ totalActualDuration - totalEstimatedDuration } h],
      ),
    )
  ],
  caption: [Tareas planeadas, duración estimada, real y desviación],
) <2-tasks>

De acuerdo a la @2-tasks[tabla], la duración inicial del proyecto se estimó en 300 horas, distribuidas entre investigación, desarrollo y documentación. Sin embargo, la duración final del proyecto ha tenido una desviación de 29 horas, resultando en 329 horas totales.

Los principales motivos para esta desviación son, principalmente, la dificultad de crear proyectos de ejemplo incrementales que contengan código limpio y sencillo para ser incrustado en el documento, y la necesidad de crear una plantilla para el documento final utilizando Typst, el software de maquetación usado.

== Análisis de costes <cost-analysis>

En esta sección proporcionaremos un resumen de los costes totales del proyecto, incluyendo costes directos e indirectos. Además, compararemos el presupuesto estimado con el presupuesto ejecutado.

=== Costes directos

Todos los gastos relacionados con el proyecto entran dentro de esta categoría, tales como el trabajo, el software y las herramientas usadas. Por un lado, todo el software utilizado a lo largo de la investigación y el desarrollo es gratuito y de código abierto, por lo que no pueden tenerse en cuenta. Así, el único gasto directo relacionado con este proyecto habría sido el salario del investigador.

#let annualGrossSalary = 41245
#let monthlyGrossSalary = annualGrossSalary / 12
#let workdaysPerMonth = 22
#let workhoursPerDay = 8
#let workhoursPerMonth = workdaysPerMonth * workhoursPerDay
#let hourlyGrossSalary = monthlyGrossSalary / workhoursPerMonth

De acuerdo a Indeed, el salario bruto anual de un ingeniero de software en España es cercano a #eur(annualGrossSalary) en 2026 @cite-indeed-software-engineer-salary, del que deducimos un salario bruto mensual de #eur(monthlyGrossSalary). El INE también publica ganancias brutas anuales desglosadas por ocupación en su Encuesta Anual de Estructura Salarial @cite-ine-wage-survey, cuya cifra en 2024 para el sector de la información y las comunicaciones fue de #eur(42741.94), corroborando el dato obtenido por el portal de trabajo.

Asumiendo una jornada laboral estándar de ocho horas al día y veintidós días de trabajo al mes, obtenemos un coste bruto por hora aproximado de #eur(hourlyGrossSalary) tras el redondeo. Podemos calcular así el coste estimado y real de cada una de las tareas, como vemos en la @2-costs[tabla].

#let tasks = tasks.map(task => (
  ..task,
  estimatedCost: task.estimatedDuration * hourlyGrossSalary,
  actualCost: task.actualDuration * hourlyGrossSalary,
))

#let totalEstimatedCost = tasks.map(task => task.estimatedCost).sum()
#let totalActualCost = tasks.map(task => task.actualCost).sum()

#figure(
  [
    #show table.cell.where(y: tasks.len() + 1): set text(weight: "bold")
    #table(
      columns: 5,
      table.header([Nº], [Tarea], [Coste \ estimado], [Coste \ real], [Desviación]),
      ..tasks
        .enumerate(start: 1)
        .map(((i, a)) => (
          [#i],
          [#a.title],
          eur(a.estimatedCost),
          eur(a.actualCost),
          eur(a.actualCost - a.estimatedCost),
        ))
        .flatten(),
      table.footer(
        [], [Total], eur(totalEstimatedCost), eur(totalActualCost), eur(totalActualCost - totalEstimatedCost)
      ),
    )
  ],
  caption: [Coste estimado, real y desviación de las tareas],
) <2-costs>

=== Costes indirectos

En este apartado tendremos en cuenta aquellos gastos que no están relacionados directamente con el proyecto, como el equipo usado. En este caso, el único equipo utilizado consiste en un ordenador personal. Dado que esto es un activo de larga duración (más de 5 años), podemos calcular una amortización simple teniendo en cuenta su coste inicial y su vida estimada.

#let computerInitialCost = 900
#let yearsOfAmortization = 8
#let monthlyAmortization = computerInitialCost / (yearsOfAmortization * 12)

Suponiendo un coste inicial aproximado de #eur(computerInitialCost) y una esperanza de vida de #yearsOfAmortization años, podemos asumir una amortización mensual de #eur(monthlyAmortization). Si además suponemos que un mes promedio tiene 30 días, es decir, 720 horas, podemos calcular la amortización total del equipo a lo largo del proyecto, como vemos en la @2-amortization[tabla].

#figure(
  [
    #show table.cell.where(y: 2): set text(weight: "bold")
    #table(
      columns: 5,
      table.header([Equipo], [Coste \ inicial], [Vida \ estimada], [Duración de \ uso], [Amortización]),
      [Ordenador \ personal],
      eur(computerInitialCost),
      [#yearsOfAmortization años],
      [#totalActualDuration h],
      eur((totalActualDuration / 720) * monthlyAmortization),

      table.footer([Total], [], [], [], eur((totalActualDuration / 720) * monthlyAmortization)),
    )
  ],
  caption: [Amortización del equipo empleado],
) <2-amortization>

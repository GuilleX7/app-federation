= Planificación del proyecto <project-planning>

En este capítulo vamos a cubrir algunos aspectos formales del proyecto. Comenzaremos explicando la metodología usada a lo largo de la elaboración del trabajo. Después, detallaremos la planificación de tareas. Finalmente, realizaremos un análisis de costes, incluyendo el coste total del proyecto y las desviaciones.

== Metodología <methodology>
Como hemos explicado en en el @goals[capítulo], el resultado final de este trabajo abarca dos productos. Por un lado, este mismo documento debe funcionar no solo como documentación exhaustiva de la biblioteca, sino como una investigación que culmina con un tutorial que visita cada uno de los problemas y las soluciones propuestas, complementándose con proyectos de ejemplo que ilustran los mecanismos alcanzados.

Por otro lado, la biblioteca final es un producto software que requiere un diseño previo a su desarrollo, pero cuyos requisitos pueden ir variando según el resultado de la investigación realizada. Así, ambos productos están estrechamente relacionados, por lo que un cambio inesperado en cualquiera de ellos provoca el consiguiente cambio en el otro.

=== Just Enough Design Up Front

La idea de usar Just Enough Design Up Front (o JEDUF, de sus siglas en inglés) emerge de combinar la necesidad de tener un diseño detallado de alto nivel, pues conocemos con exactitud cómo deben comportarse los microfrontends, con la necesidad de utilizar ciclos de desarrollo ágiles, ya que la implementación cambiará según avance la investigación.

JEDUF es una medología de desarrollo de software que establece que cada proyecto software, dependiendo de su tamaño y objetivos, tiene diferentes necesidades de diseño. En contraste con metodologías parecidas, como Big Design Up Front (BDUF) y No Design Up Front (NDUF), defiende que la necesidad de cambiar los requisitos puede surgir en cualquier momento de la vida del software, tanto durante su desarrollo como durante su uso. Así, es necesario hacer el mínimo diseño posible que sea funcional, añadiendo flexibilidad para futuras mejores y cambios.

Esto se corresponde directamente con la dirección de este proyecto: aunque podemos considerar que el tutorial, la especificación técnica y la biblioteca prototipo alcanzarán eventualmente la definición de hecho, su propia naturaleza experimental impide que realicemos un diseño excesivamente detallado desde el inicio.

Así, este proyecto trata de definir una especificación técnica a través de la implementación de referencia que, teniendo en cuenta las posibilidades ofrecidas por la mayoría de bundlers de la actualidad, sea fácilmente implementable utilizando tecnologías diferentes a las usadas en este proyecto. Todos los conceptos técnicos que se usarán para el diseño se corresponderán con ideas abstractas relacionadas con los microfrontends o la web y no con tecnologías concretas.

=== Desarrollo iterativo e incremental

Aunque existen muchas metodologías para controlar el tiempo de desarrollo, la mayoría añade una complejidad excesiva para una investigación llevada a cabo por una única persona. Así, este proyecto usa una metodología ligera derivada del desarrollo iterativo e incremental. Algunos de los puntos más remarcables son:

- *Los ciclos iterativos no tienen una duración fija.* En su lugar, cada ciclo durará el tiempo necesario para realizar la investigación necesaria, implementar la funcionalidad en la biblioteca prototipo, crear un ejemplo de referencia, probarlo, eliminar la deuda técnica y documentarlo. No obstante, el uso de hitos se mantiene, pues resulta interesante para medir el progreso a lo largo del tiempo y conocer qué partes del proyecto consumieron más recursos.

- *La documentación debe mantenerse sincronizada con el producto.* Para evitar que la documentación quede desfasada con respecto al estado real de la biblioteca, este documento incrusta código fuente de los archivos de ejemplo sin alterarlos, asegurando que lo que se escribe puede trazarse a su fuente original. Al final de cada ciclo, el documento debe ser revisado para asegurar que el código incrustado se corresponde con la documentación proporcionada.

- *Un bloqueo persistente implica rediseño.* Cuando durante un ciclo iterativo se produce un bloque de duración excesiva; por ejemplo, si tras realizar una investigación se concluye que la implementación sería muy costosa, se debe poner el foco en rediseñar el producto para sortear el problema.

== Planificación de tareas <task-planning>
#lorem(100)

== Análisis de costes <cost-analysis>
#lorem(100)
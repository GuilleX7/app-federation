#import "@preview/codly:2.0.0" as codly

#import "0300_project_analysis.typ" as req: *

#import "../utils/traceability.typ": requirementTraceabilityTable

== Comunicación entre microfrontends <communication-between-microfrontends>

Llegados a este punto, hemos finalizado con la carga de microfrontends y la inyección de estilos, pero aún no hemos definido una arquitectura explícita para la comunicación entre microfrontends. No obstante, esto es una elección deliberada. A lo largo de los ejemplos, la función `mount` de la interfaz del microfrontend aceptaba un único parámetro, el contenedor. Sin embargo, no existe ningún motivo técnico para que un número arbitrario de parámetros no pueda ser pasado a esta función, ya que se encuentra en la frontera de responsabilidades entre la librería y el código del usuario.

Dado que pasar un número arbitrario de parámetros posicionales es propenso a errores, en el @library-plugin[capítulo] el tipado de la función `mount` cambió para admitir un objeto como primer parámetro. Este objeto puede contener opcionalmente una propiedad `container` que representa el contenedor que hemos pasado en el resto de ejemplos. Sin embargo, este objeto también puede contener cualquier otra propiedad que el usuario decida pasar desde la aplicación anfitriona y recibir en la aplicación remota, como podemos ver en @4-mount-arbitrary-typing[código].

#figure(
  codly.new(
    raw(
      read("../../examples/15-props-actions/library/src/types.ts"),
      block: true,
      lang: "ts",
    ),
    ranges: ((23, 26),),
  ),
  caption: [Tipado de la función `mount`],
) <4-mount-arbitrary-typing>

Así, consideramos que la comunicación entre microfrontends no forma parte de la especificación y, por tanto, el usuario debe tener la libertad de establecer los mecanismos necesarios según su propia arquitectura. Aun así, la biblioteca proporciona una implementación básica de dos mecanismos de comunicación diferentes, los cuales pueden ser usados por el usuario de forma completamente opcional, evitando desarrollar una solución propia. En particular, se discutirá la comunicación inmediata entre aplicaciones anfitrionas y remotas y la comunicación entre árboles de microfrontends.

=== Comunicación local: props y acciones

Como hemos dicho antes, la comunicación directa entre aplicaciones anfitrionas y remotas es inmediata y, en teoría, no requiere más que pasar las propiedades necesarias en el parámetro de la función `mount`. Siguiendo patrones de frameworks como React o Vue, cada microfrontend actúa como un componente que recibe props: una aplicación anfitriona puede pasar a sus aplicaciones remotas valores, objetos o funciones, y la aplicación remota puede notificar a la anfitriona mediante callbacks o eventos @cite-react-props, @cite-vue-events. En esta biblioteca, la aplicación anfitriona pasa las props a la remota.

Dado que los props se transmiten de forma unidireccional, la aplicación anfitriona proporciona adicionalmente acciones a la remota. La aplicación remota tiene libertad de llamarlas en cualquier momento. Una acción puede mutar los props, permitiendo un intercambio de información bidireccional entre la aplicación anfitriona y la remota, como podemos ver en la @4-immediate-interaction-parent-child[ilustración].

#figure(
  image("../figures/example-15-1-props-actions.drawio.svg", width: 220pt),
  caption: [Interacción inmediata entre aplicaciones anfitrionas y remotas],
) <4-immediate-interaction-parent-child>

Sin embargo, como la función `mount` se ejecuta una única vez por instancia, no es evidente cómo la aplicación remota debe reaccionar a los cambios. Una solución es crear un sistema de suscripciones que permita registrar un callback que se invoca cuando la aplicación anfitriona cambia uno de los props.

Esta es exactamente la implementación llevada a cabo en el ámbito de este capítulo, permitiendo un manejo más complejo de la comunicación sin añadir complejidad de forma excesiva. Toda la lógica se concentra en un único archivo sin dependencias que expone un tipo llamado `AppFederationBridge`, con dos módulos bien definidos: uno para pasar props y otro para acciones, aunque este último no requiere lógica adicional, como podemos ver en @4-app-federation-bridge-definition[código].

#figure(
  codly.new(
    raw(
      read("../../examples/15-props-actions/library/src/tools/bridge.ts"),
      block: true,
      lang: "ts",
    ),
    ranges: ((3, 19),),
  ),
  caption: [Definición de `AppFederationBridge`],
) <4-app-federation-bridge-definition>

La instanciación del puente puede realizarse en el mismo instante en que el microfrontend es montado, permitiendo establecer las props iniciales y las acciones sin necesidad de líneas adicionales de código, como podemos ver en @4-instantiating-app-federation-bridge[código].

#figure(
  codly.new(
    raw(
      read("../../examples/15-props-actions/parent/src/index.ts"),
      block: true,
      lang: "ts",
    ),
    ranges: ((25, 46),),
  ),
  caption: [Instanciando `AppFederationBridge` en `parent` y pasándolo a `child`],
) <4-instantiating-app-federation-bridge>

En el lado de `child`, podemos recibir el puente de forma directa a través del primer parámetro de `mount`, como podemos ver en @4-receiving-bridge-in-child-mount[código]. Dado que `child` no tiene acceso al tipo de las props y las acciones que usa el puente, necesita redefinirlos y usarlos en la definición de `mount`. Una solución sería extraer los tipos a un archivo común entre ambos proyectos, o incluso crear una librería compartida con la interfaz de las aplicaciones, de forma que todas hagan referencia al mismo contrato.

#figure(
  codly.new(
    raw(
      read("../../examples/15-props-actions/child/src/entry.main.ts"),
      block: true,
      lang: "ts",
    ),
    ranges: ((12, 24),),
  ),
  caption: [Recibiendo `AppFederationBridge` en la función `mount` de `child`],
) <4-receiving-bridge-in-child-mount>

Así, `child` puede acceder de forma directa al valor actual de las props y suscribirse para escuchar futuros cambios de los valores, como podemos ver en @4-child-using-props[código].

#figure(
  codly.new(
    raw(
      read("../../examples/15-props-actions/child/src/entry.main.ts"),
      block: true,
      lang: "ts",
    ),
    ranges: ((33, 46),),
  ),
  caption: [`child` usando y suscribiéndose a las props recibidas de `parent`],
) <4-child-using-props>

#requirementTraceabilityTable(
  [#link(<communicationGeneralRequirement>)[#req.communicationGeneralRequirementId]],
  [#link(<shareDataAndActionsFunctionalRequirement>)[#req.shareDataAndActionsFunctionalRequirementId]],
  [#link(<resourceCleanupNonFunctionalRequirement>)[#req.resourceCleanupNonFunctionalRequirementId], #link(<typeSafetyNonFunctionalRequirement>)[#req.typeSafetyNonFunctionalRequirementId]],
  [#link(<communicateThroughDataChannelUseCase>)[#req.communicateThroughDataChannelUseCaseId]],
)

=== Comunicación global: buses

Aunque la comunicación a través de props y acciones permite la comunicación entre dos microfrontends distanciados en el árbol jerárquico, requiere que los nodos intermedios hagan de retransmisores de la información. Esto puede desembocar en un acoplamiento innecesario de los microfrontends, pues no solo necesitan saber la interfaz con la que se comunican con sus parientes más inmediatos, sino que también necesitan tener conocimiento de toda la cadena de props y acciones que pasan por ellos, requiriendo cambios en caso de moverlos en la jerarquía.

Para evitar este acoplamiento y suplir este caso de uso, la librería también proporciona una implementación simple de un bus, un mecanismo de comunicación entre microfrontends descrito también en arquitecturas de referencia @cite-andalucia-microfrontends. De forma similar al puente de props, el bus permite a sus usuarios suscribirse a un evento identificado de forma única por un ID. Todos los usuarios del bus pueden emitir cualquier evento, independientemente de su ID, y pueden acompañarlo con una carga de datos arbitraria. Es responsabilidad de los propios consumidores y productores determinar cuál debe ser el formato del ID de los eventos y los datos compartidos.

#figure(
  image("../figures/example-15-2-bus.drawio.svg"),
  caption: [Comunicación global mediante bus entre `parent`, `child` y `subchild`],
) <4-global-bus-communication>

De nuevo, la implementación se encuentra separada en un archivo sin dependencias cuyo tipado se describe en @4-app-federation-bus-definition[código].

#figure(
  codly.new(
    raw(
      read("../../examples/16-global-bus/library/src/tools/bus.ts"),
      block: true,
      lang: "ts",
    ),
    ranges: ((1, 16),),
  ),
  caption: [Definición de `AppFederationBus`],
) <4-app-federation-bus-definition>

Su uso es sencillo. En esta ocasión, vamos a definir tanto los identificadores como la carga de datos de los eventos como tipos compartidos en un archivo en común que todos los consumidores y productores del bus pueden importar, reduciendo la duplicidad del código y evitando posibles erratas. Definiremos un único evento, llamado `hello`, cuya carga de datos se compone únicamente de un parámetro, `name`, que indica el nombre del emisor del evento, como vemos en @4-hello-event-definition[código].

#figure(
  codly.new(
    raw(
      read("../../examples/16-global-bus/contract.ts"),
      block: true,
      lang: "ts",
    ),
  ),
  caption: [Definición del contrato del evento `hello`],
) <4-hello-event-definition>

Dado que el estado del bus debe ser global, el bus es instanciado por la aplicación anfitriona y transmitido por todos los microfrontends en la jerarquía. Dado que no necesitan conocer nada más que el nombre de la propiedad con la que el bus se transmite a través de `mount`, es posible desacoplar los cambios en los eventos y su carga de su posterior retransmisión. En @4-bus-instantiation-in-parent[código], la aplicación anfitriona crea el bus, se suscribe al evento `hello` que hemos definido y monta la primera aplicación remota, pasándole el bus:

#figure(
  codly.new(
    raw(
      read("../../examples/16-global-bus/parent/src/index.ts"),
      block: true,
      lang: "ts",
    ),
    ranges: ((23, 33),),
  ),
  caption: [Instanciación del bus en la aplicación anfitriona],
) <4-bus-instantiation-in-parent>

La lógica es simple: cuando un microfrontend recibe un evento `hello` cuyo emisor (`sender`) es distinto al nombre que se ha autoasignado a sí mismo, muestra el nombre del emisor en su propio contenedor. Además de introducir un nuevo microfrontend en la arquitectura, llamado `subchild`, cada aplicación incluye un botón que emite el evento con su nombre como emisor, como vemos en @4-subchild-event-emit-logic[código].

#figure(
  codly.new(
    raw(
      read("../../examples/16-global-bus/subchild/src/entry.main.ts"),
      block: true,
      lang: "ts",
    ),
    ranges: ((12, 18), (41, 48), (57, 57)),
  ),
  caption: [Lógica de emisión de eventos de `subchild`],
) <4-subchild-event-emit-logic>

Si ahora probamos a correr `parent`, `child` y `subchild`, podremos comprobar cómo, al pulsar un botón, el evento es recibido por el resto de aplicaciones, que reaccionan anunciando el nombre del emisor, como podemos ver en la @4-bus-events-example[ilustración].

#figure(
  image("../figures/example-16-1-bus-events.png"),
  caption: [Ejemplo de comunicación a través de bus entre `parent`, `child` y `subchild`],
) <4-bus-events-example>

#requirementTraceabilityTable(
  [#link(<communicationGeneralRequirement>)[#req.communicationGeneralRequirementId]],
  [#link(<exchangeEventsFunctionalRequirement>)[#req.exchangeEventsFunctionalRequirementId]],
  [---],
  [#link(<communicateThroughEventsUseCase>)[#req.communicateThroughEventsUseCaseId]],
)

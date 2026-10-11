#import "@preview/codly:1.3.0": *

== Comunicación entre microfrontends <communication-between-microfrontends>

Llegados a este punto, hemos finalizado con la carga de microfrontends y la inyección de estilos, pero aún no hemos definido una arquitectura explícita para la comunicación entre microfrontends. No obstante, esto es una elección deliberada. A lo largo de los ejemplos, la función `mount` de la interfaz del microfrontend aceptaba un único parámetro, el contenedor. Sin embargo, no existe ningún motivo técnico para que un número arbitrario de parámetros pueda ser pasado a esta función, ya que se encuentra en la frontera de responsabilidades entre la librería y el código del usuario.

Dado que pasar un número arbitrario de parámetros posicionales es propenso a errores, en el @library-plugin[capítulo] el tipado de la función `mount` cambió para admitir un objeto como primer parámetro. Este objeto puede contener opcionalmente una propiedad `container` que representa el contenedor que hemos pasado en el resto de ejemplos. Sin embargo, este objeto también puede contener cualquier otra propiedad que el usuario decida pasar desde la aplicación padre y recibir en la aplicación hija, como podemos ver en @4-mount-arbitrary-typing[código].

#codly(ranges: ((23, 26),))
#figure(
  raw(
    read("../../examples/15-props-actions/library/src/types.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Tipado de la función `mount`],
) <4-mount-arbitrary-typing>

Así, consideramos que la comunicación entre microfrontends no forma parte de la especificación y, por tanto, el usuario debe tener la libertad de establecer los mecanismos necesarios según su propia arquitectura. Aún así, la biblioteca proporciona una implementación básica de dos mecanismos de comunicación diferentes, los cuales pueden ser usados por el usuario de forma completamente opcional, evitando desarrollar una solución propia. En particular, se discutirá la comunicación inmediata entre padres e hijos y la comunicación entre árboles de microfrontends.

=== Comunicación local: props y acciones

Como hemos dicho antes, la comunicación directa entre padres e hijos es inmediata y, en teoría, no requiere más que pasar las propiedades necesarias en el parámetro de la función `mount`. Siguiendo el patrón de multitud de frameworks web, como React, Vue o Svelte, cada microfrontend actúa como un componente que recibe props, esto es, cualquier tipo de valor, normalmente primitivos (como el idioma del usuario o cualquier otro valor), aunque puede recibir cualquier tipo de valor, incluyendo referencias. Un padre pasa props a sus hijos, que las reciben unilateralmente.

Dado que los props se transmiten de forma unidireccional, el padre proporciona adicionalmente acciones al hijo. Estas también son transmitidas unidireccionalmente, pero el hijo tiene libertad de llamarlas en cualquier momento para "pedir" a la aplicación padre que realice una cierta acción. Así, una acción puede mutar o no los props, permitiendo un intercambio de información bidireccional entre la aplicación padre e hija, como podemos ver en la @4-immediate-interaction-parent-child[ilustración].

#figure(
  image("../figures/example-15-1-props-actions.drawio.svg", width: 220pt),
  caption: [Interacción inmediata entre aplicaciones padres e hijas],
) <4-immediate-interaction-parent-child>

Sin embargo, como la función `mount` se ejecuta una única vez, no es evidente cómo la aplicación hija debe reaccionar a los cambios. Una solución es crear un sistema de suscripciones que permita registrar un callback que se invoca cuando la aplicación padre cambia uno de los props.

Esta es exactamente la implementación llevada a cabo en el ámbito de este capítulo, permitiendo un manejo más complejo de la comunicación sin añadir complejidad de forma excesiva. Toda la lógica se concentra en un único archivo sin dependencias que expone un tipo llamado `AppFederationBridge`, con dos módulos bien definidos: uno para pasar props y otro para acciones, aunque este último no requiere lógica adicional, como podemos ver en @4-app-federation-bridge-definition[código].

#codly(ranges: ((3, 19),))
#figure(
  raw(
    read("../../examples/15-props-actions/library/src/tools/bridge.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Definición de `AppFederationBridge`],
) <4-app-federation-bridge-definition>

La instanciación del puente puede realizarse en el mismo instante en que el microfrontend es montado, permitiendo establecer las props iniciales y las acciones sin necesidad de líneas adicionales de código, como podemos ver en @4-instantiating-app-federation-bridge[código].

#codly(ranges: ((25, 46),))
#figure(
  raw(
    read("../../examples/15-props-actions/parent/src/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Instanciando `AppFederationBridge` en `parent` y pasándolo a `child`],
) <4-instantiating-app-federation-bridge>

En el lado de `child`, podemos recibir el puente de forma directa a través del primer parámetro de `mount`, como podemos ver en @4-receiving-bridge-in-child-mount[código]. Dado que `child` no tiene acceso al tipo de las props y las acciones que usa el puente, necesita redefinirlos y usarlos en la definiciónd de `mount`. Una solución sería extraer los tipos a un archivo común entre ambos proyectos, o incluso crear una librería compartida con la interfaz de las aplicaciones, de forma que todas hagan referencia al mismo contrato.

#codly(ranges: ((12, 24),))
#figure(
  raw(
    read("../../examples/15-props-actions/child/src/entry.main.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Recibiendo `AppFederationBridge` en la función `mount` de `child`],
) <4-receiving-bridge-in-child-mount>

Así, `child` puede acceder de forma directa al valor actual de las props, a la vez que suscribirse para escuchar futuros cambios de los valores, como podemos ver en @4-child-using-props[código].

#codly(ranges: ((33, 46),))
#figure(
  raw(
    read("../../examples/15-props-actions/child/src/entry.main.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [`child` usando y suscribiéndose a las props recibidas de `parent`],
) <4-child-using-props>

=== Comunicación global: buses

Aunque la comunicación a través de props y acciones permite la comunicación entre dos microfrontends distanciados en el árbol jerárquico, requiere que los nodos intermedios hagan de retransmisores de la información. Esto puede desembocar en un acomplamiento innecesario de los microfrontends, pues no solo necesitan saber la interfaz con la que se comunican con sus parientes más inmediatos, sino que también necesitan tener conocimiento de toda la cadena de props y acciones que pasan por ellos, requiriendo cambios en caso de moverlos en la jerarquía.

Para evitar este acomplamiento y suplir este caso de uso, la librería también proporciona una implementación simple de un bus. De forma similar al puente de props, el bus permite a sus usuarios suscribirse a un evento identificado de forma única por un ID. Todos los usuarios del bus pueden emitir cualquier evento, independientemente de su ID, y pueden acompañarlo con una carga de datos arbitraria. Es responsabilidad de los propios consumidores y productores determinar cuál debe ser el formato del ID de los eventos y los datos compartidos.

De nuevo, la implementación se encuentra separada en un archivo sin dependencias cuyo tipado se describe en @4-app-federation-bus-definition[código].

#codly(ranges: ((1, 16),))
#figure(
  raw(
    read("../../examples/16-global-bus/library/src/tools/bus.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Definición de `AppFederationBus`],
) <4-app-federation-bus-definition>

Su uso es sencillo. En esta ocasión, vamos a definir tanto los identificadores como la carga de datos de los eventos como tipos compartidos en un archivo en común que todos los consumidores y productores del bus pueden importar, reduciendo la duplicidad del código y evitando posibles erratas. Definiremos un único evento, llamado `hello`, cuya carga de datos se compone únicamente por un parámetro, `name`, que indica el nombre del emisor del evento, como vemos en @4-hello-event-definition[código].

#figure(
  raw(
    read("../../examples/16-global-bus/contract.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Definición del contrato del evento `hello`],
) <4-hello-event-definition>

Dado que el estado del bus debe ser global, el bus es instanciado por la aplicación padre y transmitido por todos los microfrontends en la jerarquía. Dado que no necesitan conocer nada más que el nombre de la propiedad con que la que el bus se transmite a través de `mount`, es posible desacoplar los cambios en los eventos y su carga de su posterior retransmisión. En @4-bus-instantiation-in-parent[código], la aplicación padre crea el bus, se suscribe al evento `hello` que hemos definido y monta la primera aplicación hija, pasándole el bus:

#codly(ranges: ((23, 33),))
#figure(
  raw(
    read("../../examples/16-global-bus/parent/src/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Instanciación del bus en la aplicación padre],
) <4-bus-instantiation-in-parent>

La lógica es simple: cuando un microfrontend recibe un evento `hello` cuyo emisor (`sender`) es distinto al nombre que se ha autoasignado a sí mismo, muestra el nombre del emisor en su propio contenedor. Además de introducir un nuevo microfrontend en la arquitectura, llamado `subchild`, cada aplicación incluye un botón que emite el evento con su nombre como emisor, como vemos en @4-subchild-event-emit-logic[código].

#codly(ranges: ((12, 18), (41, 48), (57, 57)))
#figure(
  raw(
    read("../../examples/16-global-bus/subchild/src/entry.main.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Lógica de emisión de eventos de `subchild`],
) <4-subchild-event-emit-logic>

Si ahora probamos a correr `parent`, `child` y `subchild`, podremos comprobar cómo al pulsar un botón, el evento es recibido por el resto de aplicaciones, que reaccionan anunciando el nombre del emisor, como podemos ver en la @4-bus-events-example[ilustración].

#figure(
  image("../figures/example-16-1-bus-events.png"),
  caption: [dsffs],
) <4-bus-events-example>

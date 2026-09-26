#import "@preview/codly:1.3.0": *

== Carga dinámica de microfrontends <dynamic-microfrontend-loading>

Hasta ahora, hemos visto cómo usar un bundler y hemos estudiado el esqueleto de un bundle convencional. A continuación, vamos a pasar a estudiar el comportamiento de dos proyectos: `parent`, la aplicación padre, y `child`, la aplicación hija, siendo ámbas un proyecto estándar de Rspack. Nuestro objetivo en este capítulo será cargar, instanciar y controlar `child` desde `parent` de forma programática, siguiendo una arquitectura de microfrontend típica.

=== Cargando una aplicación dentro de otra <loading-microfrontend-inside-microfrontend>

Podemos comenzar definiendo los módulos de entrada de ambos proyectos. El caso de `child` es simple: vamos a definir una función de entrada `mount` que crea un contenedor (el microfrontend) y lo añade al cuerpo del documento, como podemos ver en el @4-initial-child-mount-function[código]. Nótese que, por ahora, será el mismo `child` quien ejecute la función:

#figure(
  raw(
    read("../../examples/05-initial-microfrontend/child/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Módulo de entrada inicial de `child`],
) <4-initial-child-mount-function>

Por otro lado, en el @4-initial-parent-entrypoint[fragmento] definimos el módulo de entrada de `parent` como una pequeña aplicación que renderiza un botón que carga a `child` (una vez convertido en bundle y servido por un servidor local). La carga se hace a través del mecanismo convencional, usando etiquetas `<script>`:

#figure(
  raw(
    read("../../examples/05-initial-microfrontend/parent/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Módulo de entrada inicial de `parent`],
) <4-initial-parent-entrypoint>

Este procedimiento, sin embargo, presenta varios problemas. El más evidente es que, una vez cargado `child`, este se autoejecuta y añade su contenedor al cuerpo del documento, sin que `parent` pueda controlar cuándo y dónde debe renderizarse. Como vimos en el @4-unoptimized-bundle[ejemplo], los bundles usan el patrón IIFE para no interferir con el entorno, pero también para ejecutarse inmediatamente tras ser enlazados en un documento HTML.

=== Controlando la ejecución <managing-execution>

Para evitar este comportamiento indeseable y mantener el control de la ejecución de los microfrontends, podemos aplicar un mecanismo idéntico al JSONP que utiliza el runtime para cargar chunks. Para que JSONP funcione, necesitamos configurar tanto `child` como `parent` para que ambos conozcan el identificador de la función de carga.

Así, podemos modificar la configuración de `child` para informar a Rspack de que el bundle resultante debe usar JSONP para registrar el resultado de la ejecución de su módulo de entrada. Este es, en efecto, el objeto que contiene las funciones exportadas por el módulo, como `mount`. En particular, `library.name` indica el identificador completo de la función JSONP que se invocará para registrar el resultado del IIFE:

#codly-range(5, end: 13)
#figure(
  raw(
    read("../../examples/06-jsonp-entry/child/rspack.config.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Configurando child para usar JSONP],
) <4-configuring-child-to-use-jsonp>

Además, necesitamos algunos cambios en el código fuente: por un lado, la función `mount` necesita ser exportada para que Rspack sepa que es parte del resultado de la ejecución del módulo inicial. Por otro, `child` debe dejar de llamar a la función `mount` pasándole `document.body`, pues a partir de ahora es `parent` quien la invocará cuando crea conveniente. Veamos el resultado en el @4-child-exporting-mount[código]:

#figure(
  raw(
    read("../../examples/06-jsonp-entry/child/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Exportando `mount` desde child],
) <4-child-exporting-mount>

Tras recrear el bundle, observamos que el IIFE ahora está envuelto por la invocación al cargador JSONP, como vemos en el @4-child-using-jsonp-as-entry[código]:

#codly(ranges: ((1, 2), (57, 60)))
#figure(
  raw(
    read("../../examples/06-jsonp-entry/child/dist/main.js"),
    block: true,
    lang: "js",
  ),
  caption: [Código de entrada JSONP de `child`],
) <4-child-using-jsonp-as-entry>

A pesar de que el IIFE se sigue ejecutando inmediatamente, todos los identificadores exportados pasan a asignarse al objeto `__webpack_exports__` y son retornados al cargador. Si ahora volviésemos a abrir `parent`, veríamos que no solo el botón que carga a `child` ha dejado de funcionar, sino que se lanzan algunos errores en la consola. Esto se debe a que `child` está tratando de autoregistrar el resultado de ejecutar su módulo inicial, pero el cargador aún no existe en el objeto global `window`. Para completar la solución, necesitamos modificar la función de carga de `parent` de forma que tenga esto en cuenta, y que además ejecute la función `mount` registrada.

#codly-range(1, end: 9)
#figure(
  raw(
    read("../../examples/06-jsonp-entry/parent/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Tipado del cargador JSONP],
) <4-jsonp-loader-types>

Primero, procedemos definiendo en el @4-jsonp-loader-types[fragmento] los tipos que usarán tanto el cargador JSONP (`parentLoader`) como el objeto de retorno que contiene los métodos para controlar una instancia de microfrontend (`RuntimeModuleInstance`). Este objeto coincide con el retornado en el @4-child-using-jsonp-as-entry[código] anteriormente. Es entonces cuando podemos modificar la lógica de carga de microfrontends para añadir el cargador JSONP:

#codly(ranges: ((18, 18), (24, 32)))
#figure(
  raw(
    read("../../examples/06-jsonp-entry/parent/index.ts"),
    block: true,
    lang: "ts",
  ),
)

=== Cacheando el punto de entrada <caching-entrypoint>
=== Fábrica de instancias <instance-factory>
=== Punto de entrada dual <dual-entrypoint>
=== Contenedores de aplicaciones <containerization>

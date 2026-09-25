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
  caption: "Módulo de entrada inicial de child",
) <4-initial-child-mount-function>

Por otro lado, en el @4-initial-parent-entrypoint[fragmento] definimos el módulo de entrada de `parent` como una pequeña aplicación que renderiza un botón que carga a `child` (una vez convertido en bundle y servido por un servidor local). La carga se hace a través del mecanismo convencional, usando etiquetas `<script>`:

#figure(
  raw(
    read("../../examples/05-initial-microfrontend/parent/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: "Módulo de entrada inicial de parent",
) <4-initial-parent-entrypoint>

Este procedimiento, sin embargo, presenta varios problemas. El más evidente es que, una vez cargado `child`, este se autoejecuta y añade su contenedor al cuerpo del documento, sin que `parent` pueda controlar cuándo y dónde debe renderizarse. Como vimos en el @4-unoptimized-bundle[ejemplo], los bundles usan el patrón IIFE para no interferir con el entorno, pero también para ejecutarse inmediatamente tras ser enlazados en un documento HTML.

Para evitar este comportamiento indeseable y mantener el control de la ejecución de los microfrontends, podemos aplicar un mecanismo idéntico al JSONP que utiliza el runtime para cargar chunks. Para que JSONP funcione, necesitamos configurar tanto `child` como `parent` para que ambos conozcan el identificador de la función de carga.

Así, podemos modificar la configuración de `child` para informar a Rspack de que el bundle resultante debe usar JSONP para registrar el resultado de la ejecución de su módulo de entrada. Este es, en efecto, el objeto que contiene las funciones exportadas por el módulo, como `mount`. En particular, `library.name`
 indica el identificador completo de la función JSONP que se invocará para registrar el resultado del IIFE:

#codly-range(5, end: 13)
#figure(
  raw(
    read("../../examples/06-jsonp-entry/child/rspack.config.ts"),
    block: true,
    lang: "ts",
  ),
  caption: "Configurando child para usar JSONP",
) <4-child-using-jsonp-as-entry>

Tras recrear el bundle, observamos que el IIFE ahora está envuelto por la invocación al cargador JSONP:

#codly-range(1, end: 2)
#figure(
  raw(
    read("../../examples/06-jsonp-entry/child/dist/main.js"),
    block: true,
    lang: "js",
  ),
  caption: "Configurando child para usar JSONP",
) <4-child-using-jsonp-as-entry>


=== Controlando la ejecución <managing-execution>
=== Cacheando el punto de entrada <caching-entrypoint>
=== Fábrica de instancias <instance-factory>
=== Punto de entrada dual <dual-entrypoint>
=== Contenedores de aplicaciones <containerization>

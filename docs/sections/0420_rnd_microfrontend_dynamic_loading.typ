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

Por otro lado, en el @4-initial-parent-entrypoint[código] definimos el módulo de entrada de `parent` como una pequeña aplicación que renderiza un botón que carga a `child` (una vez convertido en bundle y servido por un servidor local). La carga se hace a través del mecanismo convencional, usando etiquetas `<script>`:

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

Tras recrear el bundle, observamos que el IIFE ahora está envuelto por la invocación al cargador JSONP, como vemos en el @4-jsonp-autoregister-in-child[código]:

#codly(ranges: ((1, 2), (57, 60)))
#figure(
  raw(
    read("../../examples/06-jsonp-entry/child/dist/main.js"),
    block: true,
    lang: "js",
  ),
  caption: [Autoregistro JSONP de `child`],
) <4-jsonp-autoregister-in-child>

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

Primero, procedemos definiendo en @4-jsonp-loader-types[código] los tipos que usarán tanto el cargador JSONP (`parentLoader`) como el objeto de retorno que contiene los métodos para controlar una instancia de microfrontend (`RuntimeModuleInstance`). Este objeto coincide con el retornado en @4-jsonp-autoregister-in-child[código] anteriormente. Es entonces cuando podemos modificar la lógica de carga de microfrontends para añadir el cargador JSONP, como vemos en @4-jsonp-loader-definition-in-parent[código]:

#codly(ranges: ((18, 18), (24, 32)))
#figure(
  raw(
    read("../../examples/06-jsonp-entry/parent/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Definición del cargador JSONP en `parent`],
) <4-jsonp-loader-definition-in-parent>

La secuencia de eventos, por tanto, es la siguiente:

1. `parent` crea la etiqueta `<script>` para cargar el bundle de `child` y la añade al cuerpo del documento.
2. Antes de retornar el control y permitir que `child` se ejecute, `parent` define el cargador JSONP en el objeto global.
3. `child` se ejecuta y registra su `RuntimeModuleInstance` en el cargador JSONP de `parent`.
4. El cargador JSONP crea un nuevo contenedor e invoca la función `mount` de child para renderizarlo.

Es importante destacar que existe una condición de carrera en esta secuencia, pues en un entorno real no podríamos garantizar que otra aplicación iniciase el proceso de carga simultáneamente y, en caso de usar el mismo cargador JSONP, este sería sobreescrito por la aplicación padre que lo defina después. Este y otros detalles relacionados serán tratados en sucesivos capítulos para evitar una complejidad excesiva desde el inicio y facilitar la lectura.

=== Cacheando el punto de entrada <caching-entrypoint>

Con la implementación actual somos capaces de controlar la ejecución de `child` gracias al cargador JSONP. Sin embargo, el proceso es algo ineficiente: cada vez que queremos crear una instancia de `child`, volvemos a cargar y ejecutar una y otra vez su bundle. Aunque normalmente un navegador cacheará el archivo descargado, la manipulación del DOM para añadir la etiqueta `<script>` es lenta y la ejecución de un script genera un overhead innecesario.

Para solucionar este problema, podemos añadir una caché con las instancias de los módulos de entrada (`RuntimeModuleInstance`) que hayamos cargado hasta ahora. Esta modificación es específica del cargador JSONP de `parent`, como podemos ver en @4-adding-runtime-cache-to-parent[código]:

#codly(ranges: ((22, 36), (43, 47)))
#figure(
  raw(
    read("../../examples/07-caching-entry/parent/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Cacheando `RuntimeModuleInstance` en `parent`],
) <4-adding-runtime-cache-to-parent>

Ahora, cargar un microfrontend varias veces usará la caché en lugar de volver a cargar el script consecutivamente. Sin embargo, este sistema no está aún completo: al cachear instancias de un microfrontend, montar la misma aplicación varias veces en distintos contenedores provocará que todas compartan el mismo estado.

Por ejemplo, si añadimos un contador a `child` usando una variable global, como se muestra en @4-adding-a-counter-to-child[código], este mantendrá su valor incluso si montamos el microfrontend varias veces. Dado que este comportamiento no es el esperado comúnmente, esto puede desembocar en multitud de errores difíciles de depurar

#figure(
  raw(
    read("../../examples/07-caching-entry/child/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Añadiendo un contador a `child`],
) <4-adding-a-counter-to-child>

=== Fábrica de instancias <instance-factory>

Para solucionar el problema introducido con la caché de instancias, podemos mover la caché un nivel hacia arriba: en lugar de cachear instancias, podemos cachear una función que genere instancias independientes. Actualmente, Rspack genera una llamada al cargador JSONP al que le pasa como argumento un IIFE que genera una instancia de `child`, por lo que simplemente envolver el IIFE en una función cumpliría la función de fábrica.

Aunque es posible modificar el resultado del bundle manualmente usando la configuración de Rspack para envolverlo en una función, podemos usar un nuevo método de carga similar a JSONP llamado AMD (del inglés _Asynchronous Module Definition_). AMD prescribe una especificación técnica para la carga de módulos de JavaScript, definiendo una API propia. Aunque la especificación es compleja, en este caso únicamente vamos a utilizar la definición de su cargador de módulos, que Rspack soporta nativamente. Primero, cambiamos la configuración de `child`:

#codly-range(5, end: 13)
#figure(
  raw(
    read("../../examples/08-runtime-factory/child/rspack.config.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Usando AMD como cargador en `child`],
) <4-using-amd-as-loader-in-child>

AMD define `amdContainer` como un objeto global que debe contener ciertos métodos. En particular, `amdContainer.define()` es el método encargado de registrar módulos de JavaScript y acepta hasta tres parámetros, `id`, `dependencies` y `factory`. En nuestro caso, y dado que estamos haciendo un uso básico de AMD, podemos usar una firma simplificada del método que únicamente acepta `factory`, y que es la que emite Rspack por defecto.

Así, si corremos Rspack de nuevo, podemos observar el nuevo autoregistro, esta vez usando la API de AMD:

#codly(ranges: ((1, 2), (60, 62)))
#figure(
  raw(
    read("../../examples/08-runtime-factory/child/dist/main.js"),
    block: true,
    lang: "js",
  ),
  caption: [Autoregistro usando AMD en `child`],
) <4-amd-autoregister-in-child>

Con este cambio, es necesario definir nuevos tipos en `parent` y cambiar la lógica del cargador:

// #codly(ranges: ((1, 13), (26, 26), (28, 29), ()))
#[
  #show figure: it => [
    #set block(breakable: true)
    #it
  ]
  #figure(
    raw(
      read("../../examples/08-runtime-factory/parent/index.ts"),
      block: true,
      lang: "js",
    ),
    caption: [Usando la API de AMD en el cargador de `parent`],
  ) <4-using-amd-in-parent-loader>
]

=== Punto de entrada dual <dual-entrypoint>
=== Contenedores de aplicaciones <containerization>
=== Atando cabos sueltos: public path y concurrencia <tying-up-loose-ends>

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

Con este cambio, es necesario definir nuevos tipos en `parent`. En particular, parentLoader ahora es un objeto que contiene el método `define`. El único parámetro que acepta es `runtimeModuleFactory`, que ahora se define como una función que devuelve una nueva instancia del microfrontend.

#codly-range(1, end: 13)
#figure(
  raw(
    read("../../examples/08-runtime-factory/parent/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Definiendo los tipos de AMD en `parent`],
) <4-defining-amd-types-in-parent-loader>

Por otro lado, la lógica del cargador también cambia: en lugar de cachear instancias, la caché contendrá fábricas, mientras que la interfaz de `window.parentLoader` cambia para definir el método `define` según la especificación AMD.

#codly(ranges: ((26, 26), (28, 29), (34, 41), (49, 54)))
#figure(
  raw(
    read("../../examples/08-runtime-factory/parent/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Usando la API de AMD en el cargador de `parent`],
) <4-using-amd-in-parent-loader>

Con estos cambios hemos conseguido realizar una única carga del script y ser capaces de crear instancias aisladas usando la misma fábrica cacheada, reduciendo el impacto en memoria y tiempo de ejecución.

=== Introduciendo un punto de entrada dual <dual-entrypoint>

Llegados a este punto, `child` se ha convertido formalmente en un microfrontend, pues puede ser cargado a petición desde `parent` y su ciclo de vida es controlable. Sin embargo, desde la introducción de JSONP y posteriormente de AMD como métodos de inyección, hemos perdido la facultad de cargar `child` de forma independiente: si tratamos de acceder a su  servidor de desarrollo directamente, observaremos una pantalla en blanco. Accediendo a la consola podremos observar el siguiente error:

#figure(
  image("../figures/example-8-error-loading-child.png"),
  caption: [Error al cargar `child` de forma independiente],
)

Esto se debe a que ahora el bundle generado depende exclusivamente de que exista un cargador global donde pueda registrarse, y de que el cargador adecuado se encargue de crear una instancia de la aplicación.

Como vimos en el @why-bundlers[capítulo], una característica común de los bundlers es que permiten definir varios puntos de entrada a la aplicación. Además de ser útil para compilar aplicaciones que están compuestas por otras subaplicaciones, esta funcionalidad es comúnmente usada para generar bundles de la misma aplicación con diferentes características. Esto se consigue añadiendo configuración específica para cada uno de los puntos de entrada. Por ejemplo, podríamos generar un bundle optimizado para navegadores antiguos y otro para navegador modernos, o generar un bundle para la web y otro para un entorno Node.js.

En nuestro caso, vamos a usar esta funcionalidad para generar dos puntos de entrada a la aplicación. Por un lado, tendremos el punto de entrada remoto (llamado `remote`), que se mantendrá idéntico a lo que hemos obtenido hasta ahora: exportará el ciclo de vida del microfrontend y se autoregistrará usando AMD. Por otro lado, vamos a registrar un nuevo punto de entrada, llamado `standalone`, que será capaz de cargar la aplicación de forma autónoma. Podemos hacer esto de varias formas:

1. Convirtiendo `standalone` en un envoltorio de `remote`, en cuyo caso `standalone` actuaría como un `parent` mínimo que usa el cargador AMD para crear una instancia de `remote`.
2. Dado que `standalone` pertenece al mismo proyecto que `remote`, importar el método `mount` de `remote` y usarlo directamente, pasándole los parámetros necesarios.

Idealmente, el primer método nos permitiría generar un bundle mínimo, ya que solo contendría el código necesario para cargar y crear una instancia de `remote`, que contiene el código de la aplicación. No obstante, dado que aún no hemos extraído el cargador AMD de `parent` a una biblioteca que podamos reusar, sería necesario duplicar el código de `parent` en el punto de entrada `standalone` de `child`. Por tanto, y debido a la sencillez de nuestro microfrontend, vamos a optar por importar e invocar `mount` de forma directa temporalmente.

Para registrar un nuevo punto de entrada, simplemente lo añadimos en la configuración de Rspack de `child`, como podemos ver en @4-registering-standalone-entry-in-child[código]:

#codly(ranges: ((4, 16), (48, 48)))
#figure(
  raw(
    read("../../examples/09-dual-entry/child/rspack.config.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Registrando el punto de entrada `standalone` en `child`],
) <4-registering-standalone-entry-in-child>

Cabe destacar que hemos renombrado el archivo `index.ts`, que hasta ahora había sido nuestro único punto de entrada, a `index.remote.ts` para denotar que es el punto de entrada remoto. Además, hemos creado `index.standalone.ts` con el siguiente contenido:

#figure(
  raw(
    read("../../examples/09-dual-entry/child/src/index.standalone.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Creando el punto de entrada `standalone` en `child`],
) <4-creating-standalone-entry-in-child>

Como podemos ver en @4-creating-standalone-entry-in-child[código], este punto de entrada es bastante simple: simplemente importa el ciclo de vida del microfrontend y lo invoca con los parámetros que espera. No obstante, cada punto de entrada genera un bundle independiente. Esto quiere decir que, si los distintos puntos de entrada comparten dependencias, se generará un chunk distinto para cada uno de los bundles, resultando en chunks duplicados y espacio en disco malgastado.

Aunque este es un problema sencillo de resolver extrayendo el código de carga de `parent` a una biblioteca para que `standalone` no importe directamente el punto de entrada `standalone`, en el siguiente apartado estudiaremos otro problema que puede resultar no tan evidente.

#figure(
  image("../figures/example-9-child-loaded.png"),
  caption: [`child` cargado de forma independiente],
)

=== Añadiendo un contenedor <containerization>

Llegados a este punto y tras lo explicado en el @dual-entrypoint[capítulo] sobre los puntos de entrada autónomos, aparece una nueva pregunta de forma  inminente: ¿cómo podemos crear varios puntos de entrada remotos sin duplicar chunks?

Si simplemente registrásemos nuevos puntos de entrada en Rspack, todo el código compartido entre ellos se duplicaría. Mientras que los puntos de entrada autónomos pueden usar el cargador para no depender directamente de los puntos de entrada remotos, estos últimos no tienen más remedio que importar directamente sus dependencias, ya que extraer la lógica común a un segundo microfrontend común añadiría complejidad excesiva y atraería errores innecesarios.

Una solución sencilla pasa por añadir un nuevo nivel de abstracción a nuestro punto de entrada remoto. Este nivel de abstracción se conoce como contenedor, y toma su nombre de un concepto similar definido en Module Federation. Hasta ahora, crear una instancia de nuestro microfrontend implicaba que se cargasen todas las dependencias de nuestro único punto de entrada para devolver su ciclo de vida. El contenedor es un módulo mínimo (sin dependencias) que actúa como paso intermedio entre la instanciación del microfrontend y la ejecución de uno de sus puntos de entrada, por lo que ningún otro módulo se instancia antes que él.

Comenzaremos moviendo la lógica actual de `index.remote.ts` en `child` a un nuevo archivo, `entry.default.ts`, que dejará de ser el punto de entrada remoto y pasará a ser uno de los puntos de entrada de la aplicación. Ahora `index.remote.ts` funcionará como contenedor y punto de entrada remoto del microfrontend, por lo que necesitará exponer una nueva interfaz para que la aplicación padre pueda elegir y cargar uno de los puntos de entrada de la aplicación, como podemos ver en @4-child-container-remote-entry[código]. Al usar `import()`, separamos los puntos de entrada usando code splitting, permitiendo que el bundler introduzca carga dinámica para el resto de chunks y, por tanto, cargando e instanciando el contenedor de forma aislada.

#codly-range(3)
#figure(
  raw(
    read("../../examples/10-containerization/child/src/index.remote.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Contenedor como punto de entrada en `child`],
) <4-child-container-remote-entry>

Además, esta interfaz también nos permitirá exponer ciertos aspectos internos del microfrontend, aportando flexibilidad tanto para realizar tareas de configuración de forma transparente al usuario, como permitiendo a este configurar de forma explícita el microfrontend antes de que este cargue sus chunks e instancie cualquiera de sus módulos. Por ejemplo, el public path del microfrontend es la ruta prefijo que este usa para cargar sus chunks. Aunque por defecto Rspack emite lógica en su runtime para autoconfigurar este valor cuando el runtime se ejecuta, puede ser útil si queremos cargar chunks desde un CDN que el bundle desconoce en build-time.

Para proporcionar más control sobre el ciclo de vida del microfrontend, vamos a introducir también un nuevo método, `unmount`, que se encarga de liberar todos los recursos relacionados con la instancia actual del mismo, y que será devuelto por el método `mount`. Para ello, necesitamos cambiar la implementación del método `mount` en `child`, como se muestra en @4-returning-unmount-lifecycle-in-child[código].

#codly(ranges: ((5, 7), (17, 20)))
#figure(
  raw(
    read("../../examples/10-containerization/child/src/entry.default.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Retornando `unmount` desde `mount` en `child`],
) <4-returning-unmount-lifecycle-in-child>

Al haber modificado la interfaz pública del punto de entrada remoto de `child`, necesitamos nuevos cambios en el cargador de `parent`. Primero, vamos a definir los nuevos tipos en @4-parent-container-types[código].

#codly(ranges: ((9, 23),))
#figure(
  raw(
    read("../../examples/10-containerization/parent/src/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Tipos del contenedor en el cargador de `parent`],
) <4-parent-container-types>

Aunque `RuntimeModuleFactory` mantiene su definición, ahora `RuntimeModuleInstance` ya no contiene el método `mount` del ciclo de vida del microfrontend, sino que expone la nueva API del contenedor. El método `loadEntry` es el encargado de cargar e instanciar el punto de entrada (`RuntimeModuleEntry`) solicitado por el usuario, donde ahora reside `mount`. Por otro lado, `mount` ya no devuelve `void`, sino que devuelve `RuntimeModuleLifecycle`, que es el objeto con el método `unmount`. Estos métodos nos permiten tener un control exhaustivo de la carga, instanciación e incluso la eliminación de cada instancia individual del microfrontend.

En cuanto al cargador de `parent`, necesitamos adaptarlo a la nueva interfaz. Tras la instanciación el contenedor, ahora necesitamos el nombre del punto de entrada de la aplicación que queremos instanciar. Esto significa que la función `loadMicrofrontend` necesita un nuevo parámetro para permitir al usuario decidir. Dado que tener un único punto de entrada a la aplicación sigue siendo un caso de uso común, usaremos el punto de entrada llamado `default` como valor por defecto en caso de omisión del parámetro, que coincide con el nombre del archivo que usamos en el punto de entrada de la aplicación anteriormente, `entry.default.ts`. Además, también cambia su valor de retorno, pues en lugar de volver `void` pasa a devolver el `RuntimeModuleLifecycle` obtenido por el método `mount`.

#codly(ranges: ((46, 49), (70, 83)))
#figure(
  raw(
    read("../../examples/10-containerization/parent/src/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Usando el contenedor en el cargador de `parent`],
)

Finalmente, añadiremos un botón para desmontar las instancias del microfrontend. Una vez obtenemos su ciclo de vida, simplemente tenemos que llamar al método `unmount`, como vemos en @4-adding-unload-for-child-instances[código]. También tenemos que eliminar el botón del DOM, ya que, si no, mantendremos la referencia al ciclo de vida de la instancia y el recolector de basura no será capaz de limpiar la memoria no utilizada.

Con esto, habremos implementado satisfactoriamente la gestión de múltiples puntos de entrada a la aplicación, evitando la duplicación de chunks y manteniendo el aislamiento de las instancias. Llegados a este punto, la API es relativamente estable. En el siguiente capítulo trataremos algunos aspectos internos del cargador y su funcionamiento, especialmente al ser usado de forma concurrente.

#codly(ranges: ((32, 42),))
#figure(
  raw(
    read("../../examples/10-containerization/parent/src/index.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Añadiendo un botón para eliminar instancias de `child`],
) <4-adding-unload-for-child-instances>

=== Public path y concurrencia <tying-up-loose-ends>



=== Migrando a una arquitectura reusable <library-plugin>

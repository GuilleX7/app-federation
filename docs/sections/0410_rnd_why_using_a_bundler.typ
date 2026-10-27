#import "@preview/codly:2.0.0" as codly

== ¿Por qué usar un bundler? <why-bundlers>

=== Optimización <bundlers-optimization>

A lo largo de este proyecto se usa de forma extensa el término bundler. En términos generales, un bundler analiza los archivos de entrada y sus dependencias, transforma el código y los recursos, y genera uno o varios archivos de salida. Según la herramienta y la configuración, esta distribución puede combinar módulos (archivos), minificar el código resultante, eliminar código no utilizado (dead code) o separarlo en partes que se cargarán bajo demanda. Por tanto, un bundler es una herramienta con múltiples propósitos y que permite una configuración extensa, permitiendo que el usuario decida qué transformaciones realizar en el proyecto @cite-webpack-code-splitting, @cite-webpack-tree-shaking.

#figure(
  image("../figures/example-1-bundler-pipeline.drawio.svg", width: 100%),
  caption: [Flujo de generación de un bundle],
) <4-bundler-pipeline>

En particular, uno de los objetivos comunes es la optimización. Por ejemplo, supongamos la plantilla HTML dada en @4-simple-html-template[código].

#figure(
  codly.new(
    ```html
    <!DOCTYPE html>
    <html>
    <head>
    <title>Hello world!</title>
    </head>
    <body>
    <p>I'm here!</p>
    </body>
    </html>
    ```,
  ),
  caption: [Plantilla HTML],
) <4-simple-html-template>

Aunque el ojo humano no detecta redundancia, el estándar HTML no exige saltos de línea entre las etiquetas. Como cada salto de línea ocupa bytes, una herramienta de minificación puede reducir el tamaño de este archivo con la representación dada en @4-minimal-simple-html-template[código]. La minificación es una transformación posible dentro del proceso de construcción; por sí sola no combina dependencias ni garantiza una mejora perceptible del tiempo de carga.

#figure(
  codly.new(
    ```html
    <!DOCTYPE html><html><head><title>Hello world!</title></head><body><p>I'm here!</p></body></html>
    ```,
  ),
  caption: [Plantilla mínima HTML],
) <4-minimal-simple-html-template>

Por supuesto, para el ojo humano, esta última plantilla es difícilmente entendible y modificable. Sin embargo, sigue siendo válida y ocupa menos bytes. Esto reduce la cantidad de datos que se transfieren, aunque el efecto en el tiempo de carga depende, entre otros factores, del tamaño total de los recursos y de la red. Un minificador incluido en la cadena de construcción puede transformar la @4-simple-html-template[plantilla] en la @4-minimal-simple-html-template[plantilla]. El resultado generado suele publicarse como un artefacto de construcción, en lugar de modificarse manualmente.

Aunque el ejemplo anterior no parece un gran beneficio, los bundlers pueden realizar otras optimizaciones que reducen el código incluido en la salida. Por ejemplo, veamos el ejemplo dado por el @4-unoptimized-dead-code[código] @cite-webpack-tree-shaking:

#figure(
  codly.new(
    ```js
    // src/constants.js
    export const DEBUG = false

    // src/main.js
    import { DEBUG } from './constants.js'

    if (DEBUG) {
      console.log("Some debug information here!")
    }

    someOtherFunction()
    ```,
  ),
  caption: [Ejemplo de dead code sin minimizar],
) <4-unoptimized-dead-code>

Este patrón es ampliamente usado en proyectos web para obtener información de depuración. Por lo general, suele existir un archivo que define constantes usadas en el proyecto y que se usan como configuración, cambiando el comportamiento de la ejecución. Aunque el código es perfectamente válido, ya que no se imprime información de depuración cuando la constante está definida como false, el archivo aún contiene la lógica y el navegador tiene que reservar espacio para la constante y ejecutar la condición, lo cual, aunque de forma mínima, ocupa espacio innecesario en la memoria y ralentiza la ejecución.

Un bundler puede tomar este código y, a través de análisis estático, producir el siguiente código optimizado (@4-minimized-dead-code):

#figure(
  codly.new(
    ```js
    // dist/main.js
    someOtherFunction()
    ```,
  ),
  caption: [Ejemplo de dead code minimizado],
) <4-minimized-dead-code>

Nótese que los dos archivos fuente del proyecto se han combinado en uno, _main.js_, y tanto la definición de la constante como la comprobación lógica han sido eliminadas del resultado. Esto se debe a que los bundlers ejecutan una lógica sofisticada para eliminar código muerto (dead code), cuya ejecución no puede darse. Entre otras optimizaciones de este estilo se encuentra el tree shaking, que reduce el contenido de los archivos fuente tomando únicamente lo que se usa de ellos, y descartando todas aquellas variables y funciones que no intervienen de ninguna manera en la ejecución. Por ejemplo, dado el fragmento mostrado en @4-unminimized-tree-shaking[código]:

#figure(
  codly.new(
    ```js
    // src/constants.js
    export const a = "Hello"
    export const b = "World!"

    // src/main.js
    import { a } from './constants.js'

    console.log(a)
    ```,
  ),
  caption: [Ejemplo de tree-shaking sin minimizar],
) <4-unminimized-tree-shaking>

Un bundler detectaría que la definición de la constante _b_ no es usada en el proyecto, descartándola del resultado final como se muestra en el fragmento de @4-minimized-tree-shaking[código]. Nótese que no solo se ha descartado la declaración innecesaria, sino que también se ha eliminado la declaración de `a` y su contenido se ha usado directamente como parámetro de `console.log`, eliminando toda la redundancia posible sin alterar el comportamiento final.

#figure(
  codly.new(
    ```js
    // dist/main.js
    console.log("Hello")
    ```,
  ),
  caption: [Ejemplo de tree-shaking minimizado],
) <4-minimized-tree-shaking>

Este procedimiento debe realizarse con cautela, pues algunos módulos tienen efectos secundarios (side effects) que modifican el comportamiento del resto del programa. Los bundlers combinan el análisis del código con información de configuración, como las declaraciones de efectos secundarios de los paquetes; por ello, no siempre pueden eliminar código de forma segura sin esa información @cite-webpack-tree-shaking.

A pesar de lo visto en este apartado, los bundlers no solo ejecutan tareas de optimización. Además, proporcionan una configuración extensa a los usuarios que permite procesar y modificar el contenido de cada archivo del proyecto a merced del usuario. Por ejemplo, es posible generar dos bundles distintos de un proyecto con distinta configuración (es decir, con distintas constantes) y optimizar cada una de estas configuraciones por separado.

También es posible reemplazar de forma dinámica el contenido de ciertos archivos del proyecto, y, además, suelen proporcionar una API que permite la reflexión, es decir, la capacidad de obtener metadatos del programa en tiempo de ejecución. Esta propiedad es fundamental para el desarrollo de este proyecto, pues es gracias a los bundlers que podremos inyectar código de forma semitransparente al usuario que habilite la arquitectura de microfrontends, como veremos en los siguientes apartados.

=== El runtime: módulos <runtime-modules>

Como ya hemos visto, la optimización es uno de los motivos por los que usamos bundlers. No obstante, existe otra funcionalidad que resulta crítica para esta investigación: el runtime que el bundler incorpora cuando funciones como la carga de chunks lo requieren. Para ilustrarlo, usaremos ejemplos reales de bundles generados por Rspack, que es el bundler usado en este proyecto.

Cabe remarcar que todos los bundlers ofrecen, de una forma u otra, un runtime. La elección de Rspack como bundler es deliberada por su extensa configuración y compatibilidad con webpack (uno de los bundlers más conocidos de la industria) y su rapidez, ya que ha sido escrito en Rust. Esto no afecta a la generalidad de la investigación ni de la biblioteca prototipo desarrollada, pues esta mantendrá la mayor parte de su lógica agnóstica del bundler, de forma que únicamente necesite pequeños adaptadores para cada bundler específico. La decisión de usar Rspack, por tanto, responde únicamente a limitaciones de tiempo y esfuerzo.

Veamos el siguiente ejemplo. Supongamos que tenemos el código fuente de un proyecto contenido en un único archivo TypeScript, llamado `main.ts`, dado por @4-optimized-basic-project[código]:

#figure(
  codly.new(
    raw(
      read("../../examples/01-minimal-optimized-bundle/index.ts"),
      lang: "ts",
      block: true,
    ),
  ),
  caption: [Proyecto básico sin minimizar],
) <4-optimized-basic-project>

TypeScript es un superconjunto de JavaScript, por lo que un navegador sería incapaz de ejecutar este programa de forma inmediata debido a la presencia de tipado. Para conseguir un resultado ejecutable, configuraremos y usaremos el bundler. Un ejemplo sencillo de configuración para nuestro bundler viene dado por @4-optimized-basic-configuracion[código]. Los archivos permiten a los usuarios decidir qué se hará con el proyecto fuente.

En nuestro caso, las líneas 4-6 indican el punto de entrada del bundler. Esto es importante, pues todos los proyectos tienen uno o varios puntos de entrada desde los que se comienzan a analizar sus dependencias, incluyendo el resto de archivos de forma transitiva mediante referencias (como import o require en JavaScript). Las líneas 7-9 indican que la carpeta que almacenará el bundle debe ser limpiada cuando se produzca un nuevo bundle, para evitar que archivos antiguos permanezcan en la misma.

Finalmente, las líneas 10-23 configuran el bundler para reconocer archivos _.ts_ (asociados con TypeScript), transpilarlos a JavaScript (para que el navegador pueda ejecutarlos) y, en concreto, para usar únicamente características de ES2017 (una versión del estándar de JavaScript). Esto permite que usemos características de versiones recientes de JavaScript en el código fuente que el bundler convertirá usando características presentes en estándares antiguos cuando sea posible, aumentando la compatibilidad de nuestro bundle.

#figure(
  codly.new(
    raw(
      read("../../examples/01-minimal-optimized-bundle/rspack.config.ts"),
      lang: "ts",
      block: true,
    ),
  ),
  caption: [Configuración básica de Rspack],
) <4-optimized-basic-configuracion>

Para nuestra sorpresa, el resultado de ejecutar nuestro bundler con esta configuración es el siguiente (@4-optimized-bundle):

#figure(
  codly.new(
    raw(
      read("../../examples/01-minimal-optimized-bundle/dist/main.js"),
      lang: "js",
      block: true,
    ),
  ),
  caption: [Bundle minimizado],
) <4-optimized-bundle>

Rspack optimiza el resultado por defecto, y dado que nuestro ejemplo era excesivamente sencillo, no podemos apreciar ningún ejemplo de runtime en el resultado, pues el bundler ha determinado que no es necesario. Podemos ver un resultado más interesante si desactivamos la optimización del bundler (@4-unoptimized-project-configuration):

#figure(
  codly.new(
    raw(
      read("../../examples/02-minimal-unoptimized-bundle/rspack.config.ts"),
      lang: "ts",
      block: true,
    ),
    ranges: ((24, 29),),
  ),
  caption: [Desactivación de la optimización de Rspack],
) <4-unoptimized-project-configuration>

Con estas nuevas instrucciones, veamos el nuevo resultado del bundle en el @4-unoptimized-bundle[código]:

#figure(
  codly.new(
    raw(
      read("../../examples/02-minimal-unoptimized-bundle/dist/main.js"),
      lang: "js",
      block: true,
    ),
  ),
  caption: [Bundle sin minimizar],
) <4-unoptimized-bundle>

Como podemos observar, el código resultante se asemeja considerablemente al código fuente, con la salvedad de que los tipos de TypeScript han sido eliminados para producir JavaScript válido, y el bundler ha producido lo que se conoce como IIFE (_Immediately Invoked Function Expression_, en inglés) en las líneas 1 y 7, una forma de garantizar que el código ejecutado no afecte al entorno en el que se encuentra, por ejemplo, con la declaración de variables globales. Esto se debe a que hemos desactivado el procedimiento de optimización, por lo que el bundler no ha ejecutado un análisis para determinar si nuestro código interfiere o no con el entorno.

Sin embargo, esto sigue siendo un ejemplo mínimo de runtime con respecto al que podríamos encontrar. Para forzar al bundler a emitir un runtime más complejo, vamos a introducir un segundo archivo al que copiaremos la definición de la función `add`. Si volvemos a ejecutar el bundler, podremos observar cómo el resultado obtenido sí que contiene un runtime mucho más sofisticado que en los casos anteriores. Sin embargo, este es tan extenso que lo desgranaremos parte por parte.

Si abrimos el archivo resultante del bundle, localizado en `examples/03-modules/dist/main.js`, el archivo inicia, como en los casos anteriores, con una IIFE para evitar que las variables del runtime de Rspack contaminen el entorno del script. Lo siguiente que encontramos es la definición de los módulos del bundle (véase el @4-runtime-modules[código]). Como hemos explicado, los bundlers reducen la cantidad de archivos resultantes. Para ello, usan un versátil sistema interno de módulos que representan archivos que en el proyecto fuente estuvieron separados en archivos. Por lo general, un archivo equivale a un módulo, aunque esto no se cumple en casos más complejos.

#figure(
  codly.new(
    raw(
      read("../../examples/03-modules/dist/main.js"),
      lang: "js",
      block: true,
    ),
    ranges: ((3, 17),),
  ),
  caption: [Declaración de módulos del runtime],
) <4-runtime-modules>

Es fácil deducir que el contenido de nuestro fichero `utils.ts` ha sido convertido en un módulo interno que expone, a través de `__webpack_exports__`, la función `add` definida anteriormente. El ID del módulo, `./utils.ts`, permite a otros cargarlo y usarlo a través de la función `__webpack_require__`. El módulo también recibe metainformación sobre sí mismo a través del parámetro `__unused_rspack_module__`, dejando entrever la capacidad de reflexión.

Otra parte interesante del runtime es la caché de módulos y la definición de `__webpack_require__`, que podemos observar en @4-runtime-module-cache[código]. El cometido de esta parte del runtime es cachear las instancias de los módulos ya ejecutados. Esto permite que los módulos mantengan su propio estado a lo largo de la ejecución del programa. Cuando otro módulo necesita cargar otro, usa la función `__webpack_require__`. Esta función primero comprueba si existe una instancia del módulo en caché, en cuyo caso la devuelve. Si no, crea una nueva instancia y la guarda en caché. Todos los módulos acceden a la misma instancia de los demás y la usan.

#figure(
  codly.new(
    raw(
      read("../../examples/03-modules/dist/main.js"),
      lang: "js",
      block: true,
    ),
    ranges: ((19, 37),),
  ),
  caption: [Declaración de la caché del runtime],
) <4-runtime-module-cache>

Por último, cabe destacar el final del archivo, que contiene el denominado entrypoint. Este se corresponde con el módulo de entrada definido en la configuración dada en @4-optimized-basic-configuracion[código]. Aunque la sintaxis no coincide exactamente con el contenido original del archivo (por ejemplo, los imports se han reemplazado por llamadas a `__webpack_require__`), el proceso de transformación realizado mantiene la misma semántica que el código original.

#figure(
  codly.new(
    raw(
      read("../../examples/03-modules/dist/main.js"),
      lang: "js",
      block: true,
    ),
    range: (64,),
  ),
  caption: [Declaración del entrypoint del runtime],
)

#figure(
  image("../figures/example-3-module-runtime-cache.drawio.svg"),
  caption: [Búsqueda, ejecución y caché de módulos en el runtime],
) <4-module-runtime-cache>

El runtime contiene más métodos que se usan en distintas partes del bundle, pero no nos enfocaremos en ellos por ahora. Como el resto del runtime, estos métodos únicamente son emitidos cuando son necesarios, optimizando de nuevo el tamaño del bundle.

=== El runtime: chunks <runtime-chunks>

Hasta ahora, tanto el runtime como los módulos estaban contenidos dentro de un mismo archivo. En proyectos mayores, un único bundle inicial puede incluir código de funcionalidades que el usuario todavía no necesita, aumentando la cantidad de JavaScript que debe descargarse antes de usarlas. La división de código permite emitir partes separadas y cargarlas bajo demanda o en paralelo; su efecto depende de cómo se divida y cargue la aplicación @cite-webpack-code-splitting.

El code splitting divide la salida en varios chunks, que pueden cargarse bajo demanda o en paralelo. Cuando se difieren funcionalidades que no son necesarias al inicio, esta técnica puede reducir el código inicial descargado y afectar positivamente al tiempo de carga; también introduce solicitudes y decisiones de particionado que deben evaluarse para cada aplicación. El chunk inicial suele incluir el runtime y los módulos necesarios para arrancar la aplicación, mientras que otros chunks se cargan cuando el runtime los solicita @cite-webpack-code-splitting.

La decisión de cuántos chunks se emiten y qué módulos contendrán depende de las reglas y opciones del bundler; no existe una distribución uniforme óptima para todos los proyectos. Las importaciones dinámicas y la configuración de división de chunks permiten al usuario influir en esa distribución @cite-webpack-code-splitting:
- Las importaciones dinámicas `import()` representan un punto de carga asíncrona que el bundler puede utilizar para separar chunks. El runtime también puede proporcionar otras funciones de carga específicas del bundler.
- La configuración del bundler, que usualmente permite modificar de forma autoritaria la emisión de chunks y los módulos que contendrán

Para analizar un ejemplo, vamos a modificar la configuración de Rspack para forzar al bundler a emitir un chunk asíncrono con el contenido de `utils.ts`. Para ello, podemos añadir el @4-force-chunk-splitting-config[bloque] a la configuración.

#figure(
  codly.new(
    raw(
      read("../../examples/04-chunks/rspack.config.ts"),
      lang: "ts",
      block: true,
    ),
    range: (29, 37),
  ),
  caption: [Forzando code splitting en la configuración],
) <4-force-chunk-splitting-config>

Al generar el bundle, esta vez obtenemos dos archivos distintos: uno contiene el runtime de Rspack junto al módulo de entrada, mientras que el contenido de `utils.ts` se ha movido a otro archivo homónimo. Si ahora inspeccionamos el entrypoint del bundle en @4-chunk-loading-entrypoint-bundle[código], la lógica ha cambiado sutilmente:

#figure(
  codly.new(
    raw(
      read("../../examples/04-chunks/dist/main.js"),
      lang: "ts",
      block: true,
    ),
    range: (151, 158),
  ),
  caption: [Bundle con carga de chunks en entrypoint],
) <4-chunk-loading-entrypoint-bundle>

`__webpack_require__.O` es una de las funciones usadas por el runtime de Rspack para comprobar si un chunk (y todos sus módulos) está cargado o no, y en caso de que no lo esté, cargarlo dentro de la definición de módulos del runtime, de forma que esté disponible para el módulo de entrada antes de que este se ejecute.

La carga de chunks es un procedimiento transparente al usuario, pero que puede configurarse y realizarse de diferentes formas. Por defecto, Rspack carga otros scripts usando la etiqueta `<script>` nativa del navegador. Una vez la etiqueta se añade al DOM, el navegador comienza la carga y ejecución del script enlazado. Como todos los scripts dentro de una misma ventana comparten un contexto global (la variable window), el script hace referencia a una función de carga definida por el runtime de Rspack previamente (conocida como chunkloader) y se autorregistra dentro del runtime. A este procedimiento se le conoce usualmente como _JSONP_ (del inglés _JSON with Padding_) y, aunque alcanzó su pico de popularidad antes de la introducción del estándar ESM, que añade otras formas de importar scripts, JSONP ha mantenido su popularidad hasta hoy por ser un método robusto y sencillo.

#figure(
  image("../figures/example-4-async-chunk-loading.drawio.svg", width: 100%),
  caption: [Secuencia de carga y registro de un chunk asíncrono con Rspack],
) <4-async-chunk-loading>

Así, ojeando el contenido del chunk asíncrono, podemos ver cómo hace uso de JSONP en @4-async-chunk-jsonp-register[código], donde `rspackChunkexamples_04_chunks` es una función global definida por el runtime de Rspack que actúa como chunkloader:

#figure(
  codly.new(
    raw(
      read("../../examples/04-chunks/dist/utils-utils_ts.js"),
      lang: "ts",
      block: true,
    ),
  ),
  caption: [Registro JSONP de un chunk asíncrono],
) <4-async-chunk-jsonp-register>


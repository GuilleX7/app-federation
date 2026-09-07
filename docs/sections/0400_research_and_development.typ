// LTeX: language=es-ES

#import "@preview/codly:1.3.0": *

= Investigación y desarrollo <research-and-development>

En este capítulo abordaremos la investigación realizada para llevar a cabo el desarrollo e implementación de la librería prototipo. Dado que se trata de un proyecto con carácter teórico-práctico, se intercalarán explicaciones teóricas con fragmentos de código provenientes de los ejemplos desarrollados.

El primer apartado servirá como una pequeña introducción al funcionamiento de los bundlers, que usaremos de forma extensa para el trabajo. El resto de subcapítulos abordará cada uno de los aspectos fundamentales de la solución, como la carga e inyección de microfrontends, la inyección de estilos y la intercomunicación entre microfrontends.

== ¿Por qué usar un bundler? <why-bundlers>

=== Optimización <bundlers-optimization>

A lo largo de este proyecto se usa de forma extensa el término bundler. Aunque existen muchos bundlers en la actualidad, todos tienen un comportamiento similar: *toman un conjunto de archivos como entrada* (normalmente archivos HTML, CSS, JavaScript u otros archivos multimedia como imágenes, vídeos, sonidos, hasta binarios WebAssembly) y *producen una salida mínima y óptima*, esto es, reducen el número de archivos, el tamaño de cada uno de ellos (eliminando información redundante, como los espacios, los comentarios o incluso minificando código o recodificando imágenes) y genera una distribución llamada bundle que mantiene el mismo comportamiento que los archivos originales.

Por ejemplo, supongamos la plantilla HTML dada en el fragmento de @4-simple-html-template[código].

#figure(
  ```html
  <DOCTYPE html>
  <html>
  <head>
  <title>Hello world!</title>
  </head>
  <body>
  <p>I'm here!</p>
  </body>
  </html>
  ```,
  caption: "Plantilla HTML",
) <4-simple-html-template>

Aunque el ojo humano no detecta redundancia, el estándar HTML no dicta que una plantilla HTML válida necesite saltos de líneas tras su etiquetas. Dado que cada salto de línea se representa con uno o dos bytes, dependiendo del sistema operativo, podemos minimizar el tamaño del archivo con la representación dada en el fragmento de @4-minimal-simple-html-template

#figure(
  ```html
  <DOCTYPE html><html><head><title>Hello world!</title></head><body><p>I'm here!</p></body></html>
  ```,
  caption: "Plantilla mínima HTML",
) <4-minimal-simple-html-template>

Por supuesto, para el ojo humano, esta última plantilla es difícilmente entendible y modificable. Sin embargo, sigue siendo válida y el archivo habría reducido su tamaño en un par de bytes, por lo que viajaría más rápido por la red y el navegador tendrá que procesar menos información. Los bundlers son los encargados de tomar la @4-simple-html-template[plantilla] y transformarla en la @4-minimal-simple-html-template[plantilla]. Como es de esperar, el resultado de un bundler no suele ser modificado posteriormente, ya que se suele considerar *inmutable*.

Aunque el ejemplo anterior no parece un gran beneficio, los bundlers son herramientas sofisticadas capaces de realizar multitud de optimizaciones, a veces no evidentes para los humanos, que permiten mejorar no solo el tamaño del resultado final, sino su optimización. Por ejemplo, veamos el ejemplo dado por el @4-unoptimized-dead-code[código]:

#figure(
  ```js
  // src/constants.js
  const DEBUG = false

  // src/main.js
  import { DEBUG } from './constants.js'

  if (DEBUG) {
    console.log("Some debug information here!")
  }

  someOtherFunction()
  ```,
  caption: "Ejemplo de dead code sin minimizar",
) <4-unoptimized-dead-code>

Este patrón es ampliamente usado en proyectos web para obtener información de depuración. Por lo general, suele existir un archivo que define constantes usadas en el proyecto y que se usan como configuración, cambiando el comportamiento de la ejecución. Aunque el código es perfectamente válido, ya que no se imprime información de depuración cuando la constante está definida como false, el archivo aún contiene la lógica y el navegador tiene que reservar espacio para la constante y ejecutar la condición, lo cual, aunque de forma mínima, ocupa espacio innecesario en la memoria y ralentiza la ejecución.

Un bundler puede tomar este código y, a través de análisis estático, producir el siguiente código optimizado (@4-dead-code-minimizado):

#figure(
  ```js
  // dist/main.js
  someOtherFunction()
  ```,
  caption: "Ejemplo de dead code minimizado",
) <4-dead-code-minimizado>

Nótese que los dos archivos fuente del proyecto se han combinado en uno, _main.js_, y tanto la definición de la constante como la comprobación lógica han sido eliminadas del resultado. Esto se debe a que los bundlers ejecutan una lógica sofisticada para eliminar código muerto (dead code), cuya ejecución no puede darse. Entre otras optimizaciones de este estilo se encuentra en tree shaking, que reduce el contenido de los archivos fuente tomando únicamente lo que se usa de ellos, y descartando todas aquellas variables y funciones que no intervienen de ninguna manera en la ejecución. Por ejemplo, dado el fragmento de @4-tree-shaking-sin-minimizar[código]:

#figure(
  ```js
  // src/constants.js
  const a = "Hello"
  const b = "World!"

  // src/main.js
  import { a } from './constants.js'

  console.log(a)
  ```,
  caption: "Ejemplo de tree-shaking sin minimizar",
) <4-tree-shaking-sin-minimizar>

Un bundler detectaría que la definición de la constante _b_ no es usada en el proyecto, descartándola del resultado final como se muestra en el fragmento de @4-tree-shaking-minimizado[código]. Nótese que no solo se ha descartado la declaración innecesaria, sino que también se ha eliminado la declaración de _a_ y su contenido se ha usado directamente como parámetro de _console.log_, eliminando toda la redudancia posible sin alterar el comportamiento final.

#figure(
  ```js
  // dist/main.js
  console.log("Hello")
  ```,
  caption: "Ejemplo de tree-shaking minimizado",
) <4-tree-shaking-minimizado>

Este es un procedimiento que debe realizarse con cautela, pues algunos fragmentos de código tienen efectos secundarios (side-effects) que modifican el comportamiento del resto de archivos. No obstante, los bundlers realizan este trabajo de manera autónoma a través de herramientas de ánalisis dinámico.

A pesar de lo visto en este apartado, los bundlers no solo ejecutan tareas de optimización. Además, proporcionan una configuración extensa a los usuarios que permite procesar y modificar el contenido de cada archivo del proyecto a merced del usuario. Por ejemplo, es posible generar dos bundles distintos de un proyecto con distinta configuración (es decir, con distintas constantes) y optimizar cada una de estas configuraciones por separado. También es posible reemplazar de forma dinámica el contenido de ciertos archivos del proyecto, y, además, suelen proporcionar una API que permite la auto-observación (en muchos ámbitos suele denominarse reflection) del proyecto desde su propio código fuente. Esta propiedad es fundamental para el desarrollo de este proyecto, pues es gracias a los bundlers que podremos inyectar código de forma semitransparente al usuario que habilite la arquitectura de microfrontends, como veremos en los siguientes apartados.

=== El runtime: módulos y chunks <runtime-modules-and-chunks>

Como ya hemos visto, la optimización es uno de los principales motivos por los que usamos bundlers hoy día. No obstante, existe otra funcionalidad que resulta crítica para esta investigación: el runtime. Para ilustrar qué es el runtime, usaremos ejemplos reales de bundles generados por Rspack, que es el bundler usado en este proyecto.

Cabe remarcar que todos los bundlers ofrecen, de una forma u otra, un runtime. La elección de Rspack como bundler es deliberada por su extensa configuración y compatibilidad con webpack (uno de los bundlers más conocidos de la industria) y su rapidez (escrito en Rust). Esto no afecta a la generalidad de la investigación ni de la librería prototipo desarrollada, pues esta mantendrá la mayor parte de su lógica agnóstica del bundler, de forma que únicamente necesite pequeños adaptadores para cada bundler específico. La decisión de usar Rspack, por tanto, responde únicamente a limitaciones de tiempo y esfuerzo.

Veamos el siguiente ejemplo. Supongamos que tenemos el código fuente de un proyecto contenido en un único archivo TypeScript, llamado _main.ts_, dado por @4-optimized-basic-project[código]:

#figure(
  raw(
    read("../../examples/01-minimal-optimized-bundle/index.ts"),
    lang: "ts",
    block: true,
  ),
  caption: "Proyecto básico sin minimizar",
) <4-optimized-basic-project>

TypeScript es un super conjunto de JavaScript, por lo que un navegador sería incapaz de ejecutar este programa de forma inmediata. Para conseguir un resultado ejecutable, configuraremos y usaremos el bundler. Un ejemplo sencillo de configuración para nuestro bundler viene dado por el @4-optimized-basic-configuracion[fragmento]. Los archivos permiten a los usuarios decidir qué se hará con el proyecto fuente.

En nuestro caso, las líneas 4-6 indican el punto de entrada del bundler. Esto es importante, pues todos los proyectos tienen uno o varios puntos de entrada desde los que se comienzan a analizar sus dependencias, incluyendo el resto de archivos de forma transitiva mediante referencias (como import o require en JavaScript). Las líneas 7-9 indican que la carpeta que almacenará el bundle debe ser limpiada cuando se produzca un nuevo bundle, para evitar que archivos antiguos permanezcan en la misma.

Finalmente, las líneas 10-23 configuran el bundler para reconocer archivos _.ts_ (asociados con TypeScript), transpilarlos a JavaScript (para que el navegador pueda ejecutarlos) y, en concreto, para usar únicamente características de ES2017 (una versión del estándar de JavaScript). Esto permite que usemos características de versiones recientes de JavaScript en el código fuente que el bundler convertirá usando características presentes en estándares antiguos cuando sea posible, aumentando la compatibilidad de nuestro bundle.

#figure(
  raw(
    read("../../examples/01-minimal-optimized-bundle/rspack.config.ts"),
    lang: "ts",
    block: true,
  ),
  caption: "Configuración básica de Rspack",
) <4-optimized-basic-configuracion>

Para nuestra sorpresa, el resultado de ejecutar nuestro bundler con esta configuración es el siguiente (@4-optimized-bundle):

#figure(
  raw(
    read("../../examples/01-minimal-optimized-bundle/dist/main.js"),
    lang: "js",
    block: true,
  ),
  caption: "Bundle minimizado",
) <4-optimized-bundle>

Rspack optimiza el resultado por defecto, y dado que nuestro ejemplo era excesivamente sencillo, no podemos apreciar ningún ejemplo de runtime en el resultado, pues el bundler ha determinado que no es necesario. Podemos ver un resultado más interesante si desactivamos la optimización del bundler (@4-unoptimized-project-configuration):

#codly-range(24, end: 29)
#figure(
  raw(
    read("../../examples/02-minimal-unoptimized-bundle/rspack.config.ts"),
    lang: "ts",
    block: true,
  ),
  caption: "Desactivación de la optimización de Rspack",
) <4-unoptimized-project-configuration>

Con estas nuevas instrucciones, veamos el nuevo resultado del bundle en el @4-unoptimized-bundle[código]:

#figure(
  raw(
    read("../../examples/02-minimal-unoptimized-bundle/dist/main.js"),
    lang: "js",
    block: true,
  ),
  caption: "Desactivación de la optimización de Rspack",
) <4-unoptimized-bundle>

Como podemos observar, el código resultante se asemeja considerablemente al código fuente, con la salvedad de que los tipos de TypeScript han sido eliminados para producir JavaScript válido, y el bundler ha producido lo que se conoce como IIFE (_Immediately Invoked Function Expression_, en inglés) en lás lineas 1 y 7, una forma de garantizar que el código ejecutado no afecte de ninguna forma al entorno en el que se encuentra (por ejemplo, con la declaración de variables globales). Esto se debe a que hemos desactivado el procedimiento de optimización, por lo que el bundler no ha ejecutado un análisis para determinar si nuestro código interfiere o no con el entorno.

Sin embargo, esto sigue siendo un ejemplo mínimo de runtime con respecto al que podríamos encontrar. Para forzar al bundler a emitir un runtime más complejo, vamos a introducir una librería de prueba en el proyecto, como podemos ver en @:

#figure(
  raw(
    read("../../examples/03-modules/dist/main.js"),
    lang: "js",
    block: true,
  ),
  caption: "Desactivación de la optimización de Rspack",
)



== Carga dinámica de microfrontends <dynamic-microfrontend-loading>

=== Cargando una aplicación dentro de otra
=== Controlando la ejecución <managing-execution>
=== Cacheando el punto de entrada
=== Fábrica de instancias
=== Punto de entrada dual
=== Contenedores de aplicaciones

== Estilos en microfrontends <microfrontend-styles>

=== Inyección rudimentaria inicial
=== Delimitando estilos: _shadow root_
=== Peculiaridades del _shadow root_

== Estado y acciones en microfrontends <microfrontend-state-and-actions>

=== Estado local: padre e hijo
=== Estado global: buses
=== Ejemplo: _routing_

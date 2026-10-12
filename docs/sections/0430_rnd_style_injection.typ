#import "@preview/codly:1.3.0": *

== Estilos en microfrontends <microfrontend-styles>

Hasta ahora, nuestros microfrontends han consistido exclusivamente de módulos JavaScript que son ejecutados e inyectados en una misma ventana. Aunque esto sigue siendo un aspecto fundamental de la arquitectura, los microfrontends suelen incluir otro tipo de archivos, como estilos en cascada, imágenes, vídeos, sonidos, entre otros.

Una de las ventajas de los bundlers es que no solo podemos transformar a voluntad todos estos archivos durante la compilación, sino que además el bundler facilita el uso de estos archivos en tiempo de ejecución dentro de nuestros módulos JavaScript. Normalmente esto implica la inclusión de estos archivos en el bundle de forma externa (el archivo se mueve al bundle y el bundler nos proporciona su ruta relativa con respecto al public path) o, a veces, de forma interna (un archivo JSON se convierte a un módulo JavaScript que exporta su contenido, permitiendo su uso directo en JavaScript).

Aunque los estilos entran dentro de esta categoría de archivos procesables, presentan algunas diferencias reseñables: la carga de estos archivos y su inclusión en el DOM provoca cambios a nivel global, pues los estilos son definidos para toda la ventana. A continuación, vamos a ver algunas de las técnicas disponibles para la inyección de estilos en microfrontends, incluyendo técnicas para el aislamiento de los mismos, contribuyendo al objetivo de lograr instancias aisladas.

=== Inyección no controlada

En general, un navegador permite hasta tres formas de inyectar estilos en el DOM:

#codly(number-format: none)

- A través de una etiqueta `<link rel="stylesheet">`, que permite cargar estilos provenientes de un archivo externo. ```html
  <link rel="stylesheet" href="global.css" />
  ```

- A través de una etiqueta `<style>`, que permite cargar estilos a través del propio contenido de la etiqueta. ```html
    <style>body { ... }</style>
  ```

- A través de la propiedad `style` de la clase `DOMElement`, presente en todos los elementos del DOM accesibles desde JavaScript, y que permite modificar los estilos de elementos individuales de forma programática. ```ts
  document.body.style.width = "100%";
  ```

#codly(number-format: numbering.with("1"))

Normalmente, los bundlers pueden emitir archivos CSS externos y asociarlos a chunks específicos. Cuando estos chunks se cargan, el runtime añade la etiqueta `<link>` correspondiente y permite que el navegador cargue estos estilos junto al chunk. Rspack también admite exportar CSS como texto o inyectarlo mediante etiquetas `<style>`, según la configuración @cite-rspack-css.

Aunque este enfoque es ideal cuando tratamos con una aplicación web que no usa microfrontends o cuando tratamos con una aplicación padre que los carga, presenta algunos problemas dentro de un microfrontend: los estilos aplicados no pueden ser modificados desde el propio microfrontend, y aunque esto no suele ser un problema para una aplicación web normal, resultará ser un inconveniente para el aislamiento de estilos entre microfrontends, como veremos en capítulos posteriores. Así, procederemos con el segundo método, la etiqueta `<style>`.

Este método suele funcionar de la siguiente forma: cuando un módulo JavaScript importa el contenido de un archivo CSS, el bundler incrusta el contenido de este como una cadena de texto dentro del módulo. Cuando el módulo de JavaScript es instanciado, el runtime del bundler invoca también un inyector de estilos que crea una etiqueta `<style>`, escribe el contenido correspondiente y la añade al documento. Este proceso se describe en la @4-style-injection-schema[ilustración].

#figure(
  image("../figures/example-13-1-style-loading-bundler.drawio.svg"),
  caption: [Esquema de la inyección de estilos dentro de JavaScript],
) <4-style-injection-schema>

Podemos configurar Rspack para inyectar etiquetas `<style>` usando una configuración básica descrita en @4-basic-configuration-for-styling[código].

#codly(ranges: ((5, 5), (12, 13), (24, 32), (51, 51)))
#figure(
  raw(
    read("../../examples/13-naive-css-injection/child/rspack.config.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Configuración básica para la inyección de estilos en Rspack],
) <4-basic-configuration-for-styling>

Para comprobar el resultado, podemos añadir un nuevo archivo CSS a nuestra aplicación `child` e importarlo dentro del punto de entrada de la aplicación. Añadiremos algunos estilos globales para la ventana, así como la definición de una clase CSS básica, como vemos en @4-global-css-content[código].

#figure(
  raw(
    read("../../examples/13-naive-css-injection/child/src/global.css"),
    block: true,
    lang: "css",
  ),
  caption: [Contenido del archivo `global.css`],
) <4-global-css-content>

Ahora, importamos este archivo en el punto de entrada de aplicación de `child`, como vemos en @4-importing-global-css-in-child[código]. El bundler procesará el archivo y lo incrustará dentro del módulo resultante.

#codly(ranges: ((7, 7), (11, 15), (20, 21), (26, 27), (31, 36)))
#figure(
  raw(
    read("../../examples/13-naive-css-injection/child/src/entry.main.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Importando `global.css` en el punto de entrada de `child`],
) <4-importing-global-css-in-child>

Si compilamos `child`, podremos observar cómo el módulo de entrada hace referencia al módulo que contiene el archivo CSS, como vemos en @4-referencing-global-css-from-entrypoint[código].

#codly(ranges: ((6, 10), (16, 17)))
#figure(
  raw(
    read("../../examples/13-naive-css-injection/child/dist/src_entry_main_ts.js"),
    block: true,
    lang: "js",
  ),
  caption: [Referencia a `global.css` desde el módulo de entrada de `child`],
) <4-referencing-global-css-from-entrypoint>

El contenido del archivo CSS ha sido incrustado como un módulo dentro del mismo chunk donde se encuentra el punto de entrada de la aplicación, como vemos en @4-global-css-as-a-module[código].

#codly(ranges: ((51, 57),))
#figure(
  raw(
    read("../../examples/13-naive-css-injection/child/dist/src_entry_main_ts.js"),
    block: true,
    lang: "js",
  ),
  caption: [Módulo generado por `global.css` en el bundle de `child`],
) <4-global-css-as-a-module>

Como vemos, la cadena de texto se pasa como parámetro a la función del runtime `__webpack_require__.is`, esto es, el inyector de estilos del runtime de Rspack, que se encuentra definido en @4-rspack-style-injector-is[código].

#codly(ranges: ((321, 329),))
#figure(
  raw(
    read("../../examples/13-naive-css-injection/child/dist/remote.js"),
    block: true,
    lang: "js",
  ),
  caption: [Definición del inyector de estilos del runtime de Rspack],
) <4-rspack-style-injector-is>

Si ahora cargamos `child` desde `parent`, observaremos que los estilos se cargan y se aplican, pero también nos enfrentamos a un problema: al inyectarse directamente en el documento, los estilos globales afectan también a elementos fuera del microfrontend. A su vez, lo opuesto también es cierto: los estilos declarados fuera del microfrontend afectan a los elementos de dentro, como podemos ver en la @4-uncontrolled-injection-child-in-parent[ilustración].

#figure(
  image("../figures/example-13-2-uncontrolled-injection.png"),
  caption: [Resultado de la inyección no controlada de estilos de `child` en `parent`],
) <4-uncontrolled-injection-child-in-parent>

=== Inyección controlada: shadow root

La inclusión de estilos dentro del mismo documento provoca conflictos entre clases y efectos no deseados. Incluso si la etiqueta tag fuese inyectada dentro del contenedor del microfrontend, sus estilos seguirían aplicándose de forma global en el documento.

Dado que tenemos acceso al contenido de las etiquetas de estilo y podemos alterar su contenido, una posible solución pasaría por modificar su contenido para renombrar todas las clases, sustituyéndolas con identificadores únicos, lo que evitaría conflictos con elementos externos al microfrontend. Sin embargo, esto tampoco solucionaría el problema con especificadores amplios (como \*),y los estilos externos seguirían afectando a los elementos internos del microfrontend.

En esta situación parece factible usar shadow root, una funcionalidad del estándar web que permite crear un árbol DOM cuya frontera limita la aplicación de estilos en ambas direcciones: las reglas de la página no seleccionan los elementos internos y las reglas internas no afectan al resto del documento @cite-mdn-shadow-dom.

#figure(
  image("../figures/example-14-1-style-clashing.drawio.svg"),
  caption: [Comparación entre un DOM sin shadow root y uno con shadow root],
) <4-style-clashing>

Como vemos en el @4-style-clashing[diagrama], necesitamos colocar tanto los estilos como el contenido del microfrontend dentro del shadow root para aplicar el aislamiento de forma adecuada. Dado que es el propio microfrontend quien crea y coloca el contenido dentro del contenedor proporcionado, parece lógico pensar que debe ser el mismo microfrontend quien cree el shadow root en el contenedor si lo necesita. Dado que la API de un shadow root difiere de la de un contenedor `<div>` normal, podemos crear un nuevo contenedor dentro del shadow root para estandarizar el comportamiento de la función `mount`, que se asegura trabajar siempre con un contenedor típico, como vemos en la @4-transforming-parent-container[ilustración].

#figure(
  image("../figures/example-14-2-standardizing-shadow-root-mount.drawio.svg"),
  caption: [Transformación del contenedor padre del microfrontend],
) <4-transforming-parent-container>

A pesar de que el microfrontend mantiene el control de los estilos, el inyector de estilos de Rspack añade los estilos al cuerpo del documento por defecto. Aunque este comportamiento es configurable, la configuración no permite seleccionar un contenedor de forma dinámica que no sea conocido en tiempo de compilación. Por ello, será necesario reemplazar el inyector de estilos y modificar los módulos CSS para que se registren en el nuevo inyector @cite-rspack-css.

Primero, necesitaremos que los módulos CSS expongan su contenido directamente, en lugar de invocar al inyector de estilos. Rspack tiene soporte nativo para esto de manera similar a la configuración que vimos en @4-basic-configuration-for-styling[código]. Sin embargo, Para evitar que el usuario tenga que aplicar el cambio manualmente, podemos modificar el plugin en tiempo de compilación para que el cambio se produzca automáticamente, sobreescribiendo la configuración del usuario, como podemos ver en @4-modifying-configuration-expose-styles[código].

#codly(ranges: ((80, 80), (82, 82), (85, 85), (98, 105), (138, 138)))
#figure(
  raw(
    read("../../examples/14-containerized-css/library/src/build/plugins/rspackPlugin.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Modificando la configuración para exponer estilos como cadenas de texto],
) <4-modifying-configuration-expose-styles>

En este punto, importar un módulo CSS únicamente nos proporcionaría su contenido, pero no se inyectaría automáticamente en el contenedor del microfrontend. Para automatizar este proceso, podemos aplicar el patrón fachada y envolver los módulos CSS con un módulo generado durante la compilación que registre su contenido en el nuevo inyector, a la vez que expone su contenido para el usuario. Debido a que la lógica es compleja, podemos mostrar el funcionamiento de forma gráfica con la @4-facade-css-module-generation[ilustración].

Una de las ventajas de esta práctica es que permite al usuario utilizar CSS Modules (no confundir con un módulo CSS del bundler). Esta técnica consiste en definir clases CSS e importar sus identificadores desde JavaScript. La herramienta transforma los nombres de clase para que tengan alcance local al módulo, reduciendo las colisiones de nombres entre hojas de estilo; por sí sola, esta técnica no encapsula la aplicación frente a todas las reglas CSS externas. Nuestro módulo fachada también exporta el contenido CSS en bruto a través del `default export` @cite-css-modules-local-scope, @cite-rspack-css.

#figure(
  image("../figures/example-14-3-css-module.drawio.svg"),
  caption: [Generación de módulos fachada para módulos de CSS],
) <4-facade-css-module-generation>

Por último, es necesario definir cómo funcionará el nuevo inyector de estilos, tanto a la hora de registrar los estilos como a la hora de registrar el contenedor donde estos estilos se inyectarán. El inyector expondrá una interfaz sencilla para registrar estilos, de forma que no solo los módulos fachada generados puedan registrarse, sino que el usuario además pueda registrar manualmente estilos en tiempo de ejecución. Esta aceptará únicamente un ID para el módulo CSS y su contenido, encargándose de la creación, sincronización e injección de etiquetas `<style>` asociadas, como se muestra en @4-css-runtime-internals[código].

#codly(ranges: ((97, 97), (99, 99), (101, 101), (105, 107), (114, 114), (125, 125)))
#figure(
  raw(
    read("../../examples/14-containerized-css/library/src/runtime/css.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Interfaz de registro de estilos CSS en el inyector],
) <4-css-runtime-internals>

Por otro lado, el registro de contenedores se hace de forma manual por el usuario. Aunque hasta ahora hemos utilizado un único contenedor en el microfrontend, no existe ningún motivo técnico para mantener esta limitación, por lo que nuestro inyector de estilos permitirá registrar cualquier número de contenedores, manteniendo copias de los estilos sincronizadas entre todos los contenedores. Usualmente esto se hará en la función `mount` del microfrontend, tal y como se muestra en @4-registering-css-containers-in-mount[código].

#codly(ranges: ((6, 8), (11, 12), (16, 20), (25, 29), (33, 33), (37, 43)))
#figure(
  raw(
    read("../../examples/14-containerized-css/child/src/entry.main.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Interfaz de registro de contenedores en la función `mount`],
) <4-registering-css-containers-in-mount>

Cabe destacar que `createStyledContainer` acepta un segundo parámetro que permite configurar su comportamiento, como habilitar o deshabilitar la creación del shadow root, que queda a elección del microfrontend. Por otro lado, el runtime también expone funciones para desregistrar módulos CSS y contenedores. Para evitar mantener el registro de todos los contenedores y módulos CSS usados, también expone una función de limpieza, `tearDownStyleScoping`, que permite liberar todos los recursos registrados anteriormente, y que suele llamarse en la función `unmount`. Podemos resumir así el funcionamiento de la inyección de estilos con el diagrama dado por la @4-complete-style-injection-architecture[ilustración].

#figure(
  image("../figures/example-14-4-css-module-runtime.drawio.svg"),
  caption: [Arquitectura final de la inyección de estilos],
) <4-complete-style-injection-architecture>

Si echamos un vistazo a `child` en @4-child-styles-standalone[ilustración], podemos ver como sus estilos se cargan adecuadamente al abrirla independientemente. Además, podemos usar la propia API expuesta por el runtime para observar el módulo CSS que se ha autoregistrado.

#figure(
  image("../figures/example-14-5-microfrontend-child-standalone.png", width: 100%),
  caption: [Estilos de `child` cargado forma independiente],
) <4-child-styles-standalone>

Por otro lado, si abrimos `parent` y cargamos `child`, podemos ver como ahora sus estilos no interfieren de ninguna forma, como se observa en @[ilustración].

#figure(
  image("../figures/example-14-6-microfrontend-parent-child.png", width: 100%),
  caption: [`parent` y `child` cargados con estilos aislados usando shadow root],
)

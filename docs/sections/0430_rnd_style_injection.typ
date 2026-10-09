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

Normalmente, los bundlers suelen recurrir al primer método si no se han configurado explícitamente para actuar de otra forma, delegando así la carga de los estilos al navegador. En este caso, el bundler produce archivos CSS externos y los asocia a chunks específicos. Cuando estos chunks se cargan, el bundler añade la etiqueta `<link>` correspondiente y permite que el navegador cargue estos estilos en paralelo al chunk.

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

Uno de los motivos de este problema es que la etiqueta `<style>` está siendo inyectada directamente en el cuerpo del documento, en lugar del contenedor del microfrontend. Esto provoca que la distancia entre la etiqueta `<style>` y el resto de elementos fuera del microfrontend se reduzca, lo cual aumenta la especifidad, es decir, la prioridad que tienen unos estilos frente a otros a la hora de decidir cuál aplicar a un elemento.

A pesar de que conseguir que la etiqueta `<style>` se inyectara dentro del contenedor del microfrontend ayudaría a aumentar la distancia entre la etiqueta de estilo y el resto de componentes fuera del microfrontend, esto no constituiría una solución definitiva, pues aquellas propiedades que no hayan sido definidas explícitamente en los elementos podrían seguir siendo sobreescritas por los estilos del microfrontend.

Dado que tenemos acceso al contenido de las etiquetas de estilo y podemos alterar us contenido, una posible solución pasaría por modificar su contenido para renombrar todas las clases con identificadores únicos, evitando conflictos con elementos fuera del microfrontend. Sin embargo, esto tampoco solucionaría el problema con especificadores amplios (como \*),y los estilos externos seguirían afectando al microfrontend.

Así, la única solución completa a este problema es usar un shadow root. Shadow root es una funcionalidad que forma parte del estándar web y que permite crear un pseudocontenedor que aisla los estilos aplicados bidireccionalmente: los estilos de fuera no se aplican dentro y viceversa.

=== Peculiaridades del shadow root

#import "@preview/codly:1.3.0": *

== Estilos en microfrontends <microfrontend-styles>

Hasta ahora, nuestros microfrontends han consistido exclusivamente de módulos JavaScript que son ejecutados e inyectados en una misma ventana. Aunque esto sigue siendo un aspecto fundamental de la arquitectura, los microfrontends suelen incluir otro tipo de archivos, como estilos en cascada, imágenes, vídeos, sonidos, entre otros.

Una de las ventajas de los bundlers es que no solo podemos transformar a voluntad todos estos archivos durante la compilación, sino que además el bundler facilita el uso de estos archivos en tiempo de ejecución dentro de nuestros módulos JavaScript. Normalmente esto implica la inclusión de estos archivos en el bundle de forma externa (el archivo se mueve al bundle y el bundler nos proporciona su ruta relativa con respecto al public path) o, a veces, de forma interna (un archivo JSON se convierte a un módulo JavaScript que exporta su contenido, permitiendo su uso directo en JavaScript).

Aunque los estilos entran dentro de esta categoría de archivos procesables, presentan algunas diferencias reseñables: la carga de estos archivos y su inclusión en el DOM provoca cambios a nivel global, pues los estilos son definidos para toda la ventana. A continuación, vamos a ver algunas de las técnicas disponibles para la inyección de estilos en microfrontends, incluyendo técnicas para el aislamiento de los mismos, contribuyendo al objetivo de lograr instancias aisladas.

=== Inyección rudimentaria inicial

En general, un navegador permite hasta tres formas de inyectar estilos en el DOM:

- A través de una etiqueta `<link rel="stylesheet">`, que permite cargar estilos provenientes de un archivo externo. ```html
  <link rel="stylesheet" href="global.css" />
  ```

- A través de una etiqueta `<style>`, que permite cargar estilos a través del propio contenido de la etiqueta. ```html
    <style>body { ... }</style>
  ```

- A través de la propiedad `style` de la clase `DOMElement`, presente en todos los elementos del DOM accesibles desde JavaScript, y que permite modificar los estilos de elementos individuales de forma programática. ```ts
  document.body.style.width = "100%";
  ```

Normalmente, un bundler que genera una aplicación web normal suele generar un documento HTML con etiquetas de tipo `<link>` para delegar la carga de los estilos al navegador cuando el documento se abra. Este enfoque es ideal cuando tratamos con una aplicación web que no usa microfrontends o cuando tratamos con una aplicación padre que los carga. En Rspack, podríamos conseguir esto [to-do: explicar cómo extraer estilos en Rspack]

[to-do: confirmar si Rspack es capaz de inyectar estilos usando la etiqueta link]
Sin embargo, este enfoque no es suficiente para la inyección de estilos en microfrontends, pues como hemos visto hasta ahora, el punto de entrada a un microfrontend es un módulo JavaScript, y no un documento HTML, por lo que el navegador no tiene siquiera conocimiento de estos archivos. En casos donde no existe la posibilidad de usar un documento HTML, o simplemente cuando queremos aumentar la portabilidad de nuestra aplicación, podemos recurrir al segundo método, la etiqueta `<style>`.

Este método suele funcionar de la siguiente forma: cuando un módulo JavaScript importa el contenido de un archivo CSS, el bundler incrusta el resultado de los archivos CSS referenciados dentro de los archivos JavaScript como cadenas de texto. Cuando los módulos de JavaScript son instanciados por el runtime del bundler, este también invoca un inyector de estilos que crea etiquetas `<style>`, escribe el contenido dentro de estas etiquetas y las añade al documento.

Podemos configurar Rspack para inyectar etiquetas `<style>` usando una configuración básica descrita en @4-basic-configuration-for-styling[código].

#figure(
  ```ts
  export default defineConfig({
    module: {
      rules: [
        {
          test: /\.css$/,
          type: "css",
        },
      ],
    },
  });
  ```,
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

Para ver el resultado, podemos observar el punto de entrada de la aplicación dentro del bundle:



=== Inyección controlada

=== Delimitando estilos: shadow root
=== Peculiaridades del shadow root

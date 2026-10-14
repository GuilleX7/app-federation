#import "@preview/codly:1.3.0": *

= Manual de usuario <user-guide>

En este capítulo, recorreremos el uso de la biblioteca de principio a fin, proporcionando instrucciones para compilarla, preparar una aplicación remota, cargarla desde otra aplicación, aislar sus estilos y compartir información entre ambas.

== Preparar la biblioteca

Los prerequisitos para preparar la biblioteca son tener una instalación válida de Node.js, incluyendo el gestor de paquetes, NPM. Cualquier versión moderna (> 18) debería ser suficiente, pero se recomienda usar la última versión estable. A fecha de escritura de este documento, se recomienda usar Node 26.

El código de la biblioteca se encuentra en el directorio `lib/`. Dado que está escrita en TypeScript es necesario transpilarla a JavaScript, proceso que generará la carpeta `lib/dist/` donde viven los archivos resultantes y que podrán importarse en otros proyectos.

Desde la raíz del repositorio, ejecutamos:

#figure(
  raw(
    read("../../examples/17-user-guide/1-build-library.sh"),
    block: true,
    lang: "sh",
  ),
  caption: [Instalando las dependencias y compilando la biblioteca],
) <user-guide-build-library>

La compilación de TypeScript genera los archivos JavaScript y las declaraciones de tipos en `lib/dist/`. Una vez compilada, es posible utilizarla en proyectos dentro del espacio de trabajo del repositorio simplemente referenciando su nombre, `@guillex7/app-federation`.

Para poder usarla en proyectos fuera del espacio de trabajo actual, debido a que la biblioteca aún no está publicada en el registro oficial de NPM, es necesario vincularla como un paquete local. Para ello, entramos al directorio `lib/` y ejecutamos `npm link`:

#figure(
  raw(
    read("../../examples/17-user-guide/2-link-library.sh"),
    block: true,
    lang: "sh",
  ),
  caption: [Habilitando la vinculación de la biblioteca],
)

Así, podemos añadirla a un proyecto externo usando el siguiente comando en la raíz del proyecto:

#figure(
  raw(
    read("../../examples/17-user-guide/3-link-library-in-project.sh"),
    block: true,
    lang: "sh",
  ),
  caption: [Vinculación de la biblioteca en un proyecto externo],
)

== Exponer una aplicación remota

Para exponer una aplicación remota, necesitamos importar y usar `AppFederationRspackPlugin` en Rspack. El plugin puede configurarse a través de un objeto que se pasa a su constructor. El único parámetro requerido es la lista de puntos de entrada de la aplicación, `entries`, representada como un objeto cuya clave es el nombre del punto de entrada y el valor debe apuntar al archivo de entrada. Si únicamente se pasa una cadena de texto, entonces el nombre de la entrada será `default` por defecto, como vemos en @5-user-guide-remote-plugin[código].

#figure(
  raw(
    read("../../examples/17-user-guide/4-remote-app-plugin-configuration.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Configuración del plugin en la aplicación remota],
) <5-user-guide-remote-plugin>

También es posible pasar otros parámetros como `remoteEntryName`, que indica el nombre del archivo resultante que contiene el punto de entrada remoto, y `amdContainer`, que indica el identificador del cargador AMD que se usará para la inyección de microfrontends (ver @instance-factory[capítulo]).

=== Interfaz del punto de entrada

Cada entrada debe exportar una función `mount`, cuya interfaz debe ser definida por el contrato entre la aplicación padre y la remota. Normalmente, este contrato incluye un contenedor, que queda reflejado en los tipos de App Federation. Sin embargo, esto es opcional, y la función puede aceptar cualquier otro parámetro. El resultado de ejecutar la función `mount` es un objeto (o una promesa que devuelve un objeto) que contiene el método `unmount`, que debe liberar todos los recursos de la instancia de la aplicación.

#figure(
  raw(
    read("../../examples/17-user-guide/5-remote-entry-mount-interface.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Contrato de montaje de una entrada remota],
) <user-guide-remote-mount>

=== Inyectar estilos en la aplicación remota

Para que el plugin pueda procesar los módulos CSS importados por la aplicación remota, es necesario introducir una regla de procesado CSS como convencional de Rspack. No es necesario añadir ninguna configuración específica, pues el plugin se encarga de modificar la regla para usar el inyector de estilos de App Federation.

#figure(
  raw(
    read("../../examples/17-user-guide/6-remote-entry-css-config.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Regla CSS de Rspack junto al plugin de la biblioteca],
) <user-guide-css-rspack>

Una vez añadida, los estilos son procesados por App Federation, pero no son inyectados automáticamente. Es responsabilidad de la aplicación remota inyectarlos en los contenedores necesarios usando `createStyledContainer` en cualquier punto de la aplicación, aunque normalmente esto se hará en el método `mount`, como vemos en @4-user-guide-css-container[código].

#figure(
  raw(
    read("../../examples/17-user-guide/7-remote-entry-style-inyection.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Inyección de estilos en un contenedor de la aplicación remota],
) <4-user-guide-css-container>

Por defecto, `createStyledContainer` crea un `ShadowRoot` abierto y crea un contenedor adicional donde podemos montar la interfaz. Así, las reglas CSS de la aplicación quedan dentro de esa frontera y no seleccionan el resto de la página. Es posible cambiar este comportamiento con los parámetros `createShadowRoot` y `returnNestedContainer`, que se pasan dentro de un objeto como primer parámetro.

Cuando se usa shadow root, las reglas `@font-face` se extraen de los estilos inyectados y registran en `document.head` para que el navegador pueda resolver las fuentes. Esto se debe a un problema en los principales navegadores web @cite-browser-shadow-root-css-issue. Además, el selector `:root` es transformado en el selector `:host` para asegurarse de que se aplica al shadow root.

En el método `unmount` se llama a la función `tearDownStyleScoping`, que permite eliminar todos los contenedores y shadow roots creados y limpia la memoria asociada con la inyección de estilos de la instancia.

=== Cargar la aplicación remota de forma independiente

Podemos definir un punto de entrada independiente en el bundler que use la biblioteca para cargar su punto de entrada remoto. Dado que el punto de entrada remoto se encuentra en el mismo bundle, es posible usar rutas relativas para cargarlo:

#figure(
  raw(
    read("../../examples/17-user-guide/8-remote-app-standalone-entry.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Punto de entrada independiente de la aplicación remota],
)

A continuación, registramos el punto de entrada independiente en la configuración de Rspack:

#figure(
  raw(
    read("../../examples/17-user-guide/9-remote-app-standalone-config.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Registro del punto de entrada independiente de la aplicación remota],
)

Si hay un plugin HTML registrado en Rspack, es necesario indicarle que no incluya el chunk que contiene el punto de entrada remoto. Para ello, especificamos que únicamente incluya el punto de entrada independiente:

#figure(
  raw(
    read("../../examples/17-user-guide/10-remote-app-html-chunk-plugin.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Limitando los chunks incluidos en el HTML de la aplicación remota],
)

== Cargar una aplicación remota desde la anfitriona

Para cargar una aplicación remota, la aplicación anfitrión solo necesita tener instalada la biblioteca. Existen varias funciones disponibles: `loadAppInstance`, que carga el punto de entrada remoto y crea una nueva instancia de la aplicación, y `loadAppInstanceEntry`, que además pide a la aplicación que cargue uno de sus puntos de entrada dado como parámetro. En caso de omisión, se carga el punto de entrada `default`.

Ambas funciones aceptan la URL del archivo remoto. Una vez obtenido el punto de entrada de la aplicación, es responsabilidad del anfitrión llamar a `mount` con los parámetros necesarios y conservar el ciclo de vida devuelto para poder desmontar la aplicación en el futuro, como vemos en @5-user-guide-load-remote[código].

#figure(
  raw(
    read("../../examples/17-user-guide/11-load-remote-entry.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Carga y montaje de una entrada remota],
) <5-user-guide-load-remote>

== Compartir información entre aplicaciones

La biblioteca ofrece dos mecanismos sencillos. El puente (`AppFederationBridge`) sirve para la comunicación directa entre una aplicación padre y una hija. El bus (`AppFederationBus`) permite que varias aplicaciones intercambien eventos sin retransmitirlos por cada nivel de la jerarquía. En ambos casos conviene definir los tipos compartidos en un contrato que puedan importar los participantes.

#figure(
  raw(
    read("../../examples/17-user-guide/12-bridge-host.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Creación de un puente y un bus en la aplicación anfitriona],
) <5-user-guide-bridge-host>

Nótese que es responsabilidad del anfitrión llamar al método `bus.dispose()` para limpiar la memoria asociada al bus. Esto debe ocurrir cuando todas las aplicaciones que usan el bus ya no estén montadas.

La aplicación hija recibe el puente y el bus a través de los parámetros de `mount`. Dado que por defecto `mount` no define ninguno de estos campos, es necesario proporcionar los tipos adecuados en la propia definición de la función, como vemos en @5-user-guide-bridge-child[código].

#figure(
  raw(
    read("../../examples/17-user-guide/13-bridge-remote.ts"),
    block: true,
    lang: "ts",
  ),
  caption: [Recibiendo el puente y el bus en la aplicación remota],
) <5-user-guide-bridge-child>

`AppFederationBridge` permite usar las acciones definidas por la aplicación anfitriona fácilmente, solo es necesario invocar los métodos correspondientes en el puente. Por ejemplo, si la acción `selectProduct` está definida en el puente, la aplicación remota puede llamarla así:

#raw(
  read("../../examples/17-user-guide/14-bridge-action.ts"),
  block: true,
  lang: "ts",
)

Las props definidas pueden ser accedidas de forma síncrona o a través de una suscripción a los cambios en el puente. Por ejemplo:

#raw(
  read("../../examples/17-user-guide/15-bridge-props.ts"),
  block: true,
  lang: "ts",
)

Para usar el bus y escuchar eventos se puede usar el método `subscribe`, que devuelve una función para cancelar la suscripción.

#raw(
  read("../../examples/17-user-guide/16-bus-subscribe.ts"),
  block: true,
  lang: "ts",
)

Para emitir eventos a través del bus, es necesario usar el método `emit`, pasando como parámetros el nombre del evento y la carga de datos asociada.

#raw(
  read("../../examples/17-user-guide/17-bus-emit.ts"),
  block: true,
  lang: "ts",
)


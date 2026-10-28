#import "../themes/content.typ": content-theme

#show: content-theme

= Introducción <introduction>

== Motivación <motivation>

En los últimos veinticinco años, el ecosistema web ha experimentado cambios a un ritmo vertiginoso. Al inicio del siglo, los desarrolladores construían sitios mayoritariamente estáticos utilizando únicamente lenguajes de marcado como HTML y CSS. Los sitios dinámicos, que eran una minoría, usaban tecnologías del lado de servidor (como PHP, Java o ASP) que emitían el marcado. Esto relegaba JavaScript únicamente a pequeños scripts que mejoraban la experiencia de usuario o que introducían una solución alternativa a problemas que no podían solucionarse solo con lenguaje de marcado.

La evolución de JavaScript, la aparición de nuevos estándares web y su implementación en los navegadores han facilitado la creación de interfaces cada vez más complejas en el cliente. Un patrón habitual es la Single Page Application o SPA: una aplicación que carga un documento web y actualiza su contenido mediante JavaScript cuando cambia la vista, en lugar de cargar un documento nuevo en cada navegación @cite-mdn-spa.

Con la expansión de las SPA y la aparición de frameworks cada vez más potentes para el frontend, también crecieron las necesidades del proceso de construcción de aplicaciones web. Los bundlers analizan las dependencias de un proyecto y transforman su código y recursos para su distribución. Según la herramienta y su configuración, la salida puede consistir en uno o varios archivos optimizados e incluir minificación, eliminación de código no utilizado y división del código en partes que se cargan bajo demanda. Estas técnicas pueden reducir el código transferido inicialmente, aunque el resultado y su efecto en el rendimiento dependen de la aplicación y de la configuración @cite-webpack-code-splitting, @cite-webpack-tree-shaking.

En proyectos grandes, especialmente en organizaciones con varios equipos, mantener y evolucionar una aplicación frontend monolítica puede plantear desafíos de coordinación y despliegue. Cuando varias personas o equipos trabajan sobre una misma aplicación no solo aumenta el tamaño del código, sino que inevitablemente se producen acoplamientos de módulos internos, provocando que el despliegue de cambios en uno de ellos a producción arrastre cambios en los demás. Una división en partes más pequeñas puede ayudar a que cada equipo trabaje con mayor autonomía y entregue sus cambios sin esperar a que toda la aplicación se actualice a la vez. Para que esta separación sea útil, las partes deben tener límites claros y la integración debe permitir que el usuario siga percibiendo un único producto @cite-fowler-microfrontends, @cite-peltonen-microfrontends-review,  @cite-andalucia-microfrontends.

Los microfrontends plantean una forma de organizar esa separación en el frontend. Cada equipo puede mantener una aplicación web con sus propias herramientas y ciclo de desarrollo, mientras que una anfitriona actúa como conexión entre todas las partes individuales. Así, es posible actualizar o sustituir una parte sin reconstruir necesariamente las demás. Sin embargo, la independencia tiene un coste: se deben coordinar la navegación, los estilos y la comunicación entre aplicaciones para tratar de proporcionar una experiencia visual lógica. Para llevar a cabo la comunicación es necesario definir una interfaz estricta entre las diferentes aplicaciones y la aplicación anfitriona. Aunque esto es una responsabilidad adicional, también ayuda a hacer evidente el acoplamiento innecesario y reducirlo.

Por todos estos motivos, adoptar una arquitectura basada en microfrontends no consiste simplemente en dividir un proyecto en varios repositorios, sino que también es necesario escoger cómo se publican las aplicaciones, cómo se cargan y qué responsabilidades asume cada aplicación. En el siguiente apartado estudiaremos algunas de las soluciones del ecosistema y sus distintas decisiones sobre estos aspectos.

== Estado del arte <state-of-the-art>

Como hemos explicado en el @motivation[apartado], el término microfrontend describe una forma de organizar una aplicación, no un formato de archivo ni un framework concreto. En general, cada microfrontend es un proyecto web normal, tiene sus propias dependencias, usa su propio framework y puede generar, aunque no siempre, los archivos HTML, CSS y JavaScript habituales. Por lo general, una solución de microfrontends no limita las tecnologías que se pueden usar en un proyecto, colocándose así en una capa por debajo de los frameworks y las bibliotecas convencionales.

Una de las principales diferencias de los microfrontends con respecto a las páginas web convencionales es que, en lugar de abrirlos a través de un archivo HTML que se sirve directamente al navegador, es una aplicación anfitriona la que utiliza una biblioteca para cargar los microfrontends en su propia página. Aunque el navegador sigue descargando y ejecutando los archivos, es la biblioteca quien coordina esa carga y, según la solución, obtiene el punto de entrada, prepara el entorno y monta la interfaz visible por el usuario en un contenedor de la página. Por tanto, el proyecto remoto debe cumplir el formato o el ciclo de vida que espera la biblioteca, aunque en algunas soluciones este requisito no es demasiado estricto, permitiendo que la aplicación pueda seguir ejecutándose por separado o no necesite modificaciones en absoluto @cite-fowler-microfrontends, @cite-single-spa-apps, @cite-micro-app.

Debido a la fragmentación del ecosistema, es difícil encontrar una lista exhaustiva de las implementaciones de microfrontends existentes y sus cuotas de mercado. Por ello, este análisis compara seis implementaciones seleccionadas para ilustrar distintos enfoques: Module Federation, single-spa, qiankun, Native Federation, Garfish y micro-app.

=== Module Federation

Module Federation es una solución de microfrontends que permite que una aplicación exponga módulos (esto es, principalmente, archivos JavaScript) y que otra los consuma sin incluirlos directamente en su propio proyecto. La aplicación remota genera, a través del uso de un plugin en el bundler, un punto de entrada con información sobre los módulos expuestos, denominado manifiesto. La aplicación anfitriona puede cargar el punto de entrada y utilizar los módulos expuestos cuando lo necesite.

Esta implementación requiere que al menos la aplicación remota modifique su compilación para generar el manifiesto. La aplicación anfitriona puede registrar las aplicaciones remotas que desea utilizar en tiempo de compilación, aunque también puede cargar aplicaciones remotas dinámicamente según sea necesario @cite-module-federation-runtime.

Aunque Module Federation facilita la compartición de módulos y dependencias entre aplicaciones, no abstrae completamente la gestión del ciclo de vida ni el aislamiento de estilos, pues exige que la aplicación anfitriona decida por sí sola cuándo se carga una aplicación, en qué contenedor se monta o cómo se controla su ciclo de vida. Además, Module Federation tampoco proporciona herramientas para inyectar o delimitar los estilos de cada aplicación. @cite-mf-style-isolation.

=== single-spa

A diferencia de Module Federation, single-spa es principalmente un orquestador de aplicaciones. La aplicación anfitriona registra cada microfrontend con una función de carga y una condición que determina cuándo debe cargarse y mostrarse. Por ejemplo, al cambiar la ruta de la página, single-spa decide qué aplicación debe estar activa en ese momento y gestiona su ciclo de vida, inicializándola, montándola y desmontándola cuando ya no sea necesaria. @cite-single-spa-configuration, @cite-single-spa-apps.

Este enfoque difiere especialmente de Module Federation, ya que requiere que las aplicaciones y sus rutas se conozcan de antemano. Aunque esto proporciona una mayor visibilidad de la arquitectura, también limita la flexibilidad en tiempo de ejecución. Si la lista de aplicaciones cambia en tiempo de ejecución, la aplicación anfitriona necesita gestionar esos cambios mediante código adicional. single-spa también proporciona algunas utilidades como la inyección de estilos, aunque no proporciona aislamiento completo de los mismos.

=== qiankun

qiankun es una solución de microfrontends basada en single-spa. Su principal diferencia es que añade un cargador dinámico de aplicaciones utilizando archivos HTML, solventando la limitación de conocer todas las aplicaciones y sus rutas de antemano @cite-qiankun-migration, @cite-qiankun-runtime.

Sin embargo, qiankun también implementa un sandbox de JavaScript, añadiendo una capa de ejecución entre la aplicación remota y el navegador. Además, algunas aplicaciones que dependen de variables globales o de referencias a variables de otros microfrontends pueden requerir ajustes. El aislamiento de estilos también mantiene los mismos límites que single-spa, por lo que no cuenta con aislamiento completo @cite-qiankun-style-isolation.

=== Native Federation

Native Federation toma su idea de Module Federation en cuanto a compartir módulos de aplicaciones, pero se apoya en el uso de módulos ES y mapas de importación del navegador. Dado que estos estándares son relativamente modernos, su soporte para navegadores antiguos es limitado. De forma similar a Module Federation, un plugin en el bundler prepara los módulos expuestos y genera el manifiesto que describe qué archivos se deben cargar.

En el lado del navegador, la aplicación anfitriona usa una biblioteca que utiliza los manifiestos para importar los módulos remotos @cite-native-federation-architecture. Al igual que Module Federation, no proporciona ningún tipo de control sobre el ciclo de vida, la inyección de estilos o la comunicación entre microfrontends, por lo que no es una solución completa, sino una versión de Module Federation con diferentes tecnologías. @cite-native-federation-runtime.

=== Garfish

Garfish puede cargar microfrontends a través de archivos HTML o JavaScript indistintamente. De forma similar a single-spa, la aplicación anfitriona puede declarar aplicaciones en un manifiesto y especificar para qué rutas o condiciones se cargarán, dejando que Garfish gestione su ciclo de vida. Sin embargo, también permite cargarlas de forma dinámica, similar a Module Federation.

Además del cargador, el framework incluye funciones de comunicación entre microfrontends, sandbox de JavaScript y un sistema de inyección y aislamiento de estilos, convirtiéndola en una de las implementaciones más completas de entre las estudiadas @cite-garfish. Sin embargo, su documentación se encuentra escrita únicamente en chino y su funcionamiento no es claro. Además, la incorporación de todos estos sistemas aumenta la complejidad y los fallos potenciales y reduce la velocidad de ejecución.

=== micro-app

micro-app utiliza un enfoque radicalmente distinto: usa Web Components y convierte la aplicación remota en un elemento que la aplicación anfitriona puede insertar directamente en la página. Al cargar un microfrontend, la biblioteca crea un nuevo elemento, inyecta su contenido y delega el aislamiento de la aplicación al navegador. @cite-micro-app.

Esta idea simplifica la forma de integrar la aplicación, ya que la aplicación remota no difiere de otras etiquetas HTML, pero deja toda la responsabilidad sobre el ciclo de vida de los microfrontends en la aplicación remota. Por otro lado, también depende de APIs del navegador modernas como Custom Elements y Proxy, lo que puede limitar su uso en navegadores antiguos.

=== Comparación y limitaciones <comparison-and-limitations>

Aunque muchas de las soluciones presentadas comparten ciertas características y funcionalidades, las seis cubren necesidades diferentes.

Soluciones como single-spa proporcionan un framework que cubre todo lo relacionado al ciclo de vida de los microfrontends, facilitando una definición declarativa de la arquitectura @cite-single-spa-api, además de proporcionar algunas herramientas para la integración adecuada de microfrontends, como la inyección de estilos. Aunque este enfoque puede ser útil en algunos casos, puede limitar la flexibilidad a la hora de cargar aplicaciones dinámicamente, y tampoco proporciona herramientas completas para el aislamiento de estilos.

Las soluciones federadas como Module Federation y Native Federation solucionan algunos de los problemas derivados de la estrategia declarativa de single-spa: aunque es común registrar microfrontends en tiempo de compilación, estos también pueden ser cargados de forma dinámica en tiempo de ejecución @cite-module-federation-runtime, @cite-native-federation-runtime. Ambas son además soluciones cooperativas, pues no incorporan sandboxing de los microfrontends, reduciendo su complejidad. Sin embargo, presentan algunas carencias: al estar enfocadas en módulos, no tienen soporte completo para la carga de aplicaciones, el manejo del ciclo de vida, la inyección de estilos o el aislamiento de los mismos, lo que requiere que el usuario haga su propia implementación @cite-mf-style-isolation.

Por otro lado, las soluciones como qiankun, Garfish o micro-app no requieren ningún registro de antemano ni modificación en el proceso de compilación de los microfrontends y únicamente requieren mínimos cambios en run-time. Este paradigma conlleva el uso de sandboxing, dado que las aplicaciones remotas no cooperan de ninguna forma con la aplicación anfitriona y, por tanto, es necesario aislarlas del entorno de forma estricta. Aunque esto ayuda a conseguir una separación de responsabilidades estricta y previene que los errores se propaguen de aplicaciones remotas a anfitrionas o viceversa, también introduce un mecanismo muy complejo y pesado que, además de introducir posibles bugs, puede reducir el rendimiento o aumentar el tamaño final del bundle. Además, las vuelve más difíciles de entender y de extender.

Podemos resumir las diferencias entre las distintas soluciones clasificándolas de acuerdo a tres categorías:

- *Paradigma*: algunas soluciones requieren registrar los microfrontends en la aplicación anfitriona de forma *declarativa*, mientras que otras permiten cargar microfrontends de forma completamente *programática*, sin necesidad de registro previo o metadatos más allá de la dirección donde reside el punto de entrada (como veremos en el @managing-execution[capítulo]).

- *Aislamiento*: mientras que algunas implementaciones comparten el mismo entorno entre aplicaciones anfitrionas y remotas (*cooperativas*), otras garantizan el aislamiento de los microfrontends utilizando técnicas avanzadas de aislamiento como la interpretación de JavaScript embebida (*sandboxed*).

- *Tiempo de ejecución*: una implementación puede ser completamente agnóstica con respecto a las herramientas de compilación (bundlers) y funcionar sin modificar los microfrontends en absoluto (en cuyo caso diríamos que es una implementación en *run-time*), o puede requerir modificar la compilación de los microfrontends para añadir parte o la totalidad de la funcionalidad (*build-time*).

#[
  #show table.cell.where(y: 0): set text(weight: "bold")
  #figure(
    table(
      columns: 4,
      table.header[Implementación][Paradigma][Aislamiento][Tiempo de ejecución],
      [Module Federation], [Semideclarativo], [Cooperativo], [Build-time],
      [single-spa], [Declarativo], [Cooperativo], [Run-time],
      [qiankun], [Programático], [Sandboxed], [Run-time],
      [Native Federation], [Semideclarativo], [Cooperativo], [Build-time],
      [Garfish], [Programático], [Sandboxed], [Run-time],
      [micro-app], [Programático], [Sandboxed], [Run-time],
    ),
    caption: [Clasificación de implementaciones de microfrontends],
  ) <1-microfrontend-comparison>
]

== Objetivos <goals>

De la comparación dada en el @comparison-and-limitations[apartado] extraemos la necesidad que trataremos de cubrir con este trabajo.

- Una solución basada solo en configuración previa dificulta cargar aplicaciones que se descubren en tiempo de ejecución
- Una solución que intenta aislar cualquier aplicación sin modificar su compilación añade mecanismos complejos al navegador
- Una solución federada resuelve la carga de módulos de forma simple, pero no proporciona por sí sola una interfaz sencilla para instanciar y desmontar aplicaciones completas

Así, para este proyecto encontramos adecuado estudiar un enfoque *programático*, *cooperativo* y *build-time*: la aplicación anfitriona podrá cargar una aplicación remota indicando su dirección, mientras que una modificación mínima y explícita de la compilación añade las modificaciones necesarias para permitir la integración de forma cooperativa y sin necesidad de sandboxing. Al compartir el entorno de JavaScript, las aplicaciones podrán comunicarse directamente, reduciendo la complejidad y aumentando la velocidad. Esta serie de elecciones no trata de ser la mejor para todos los casos de uso, sino ofrecer una base sencilla para estudiar la integración y sus responsabilidades.

Este documento propone estudiar, definir e implementar una solución académica de microfrontends, manteniendo la simplicidad para su estudio y extensión posterior, tanto por futuras investigaciones como para cubrir necesidades específicas de las organizaciones que decidan usarla como base para sus propias soluciones. No obstante, el resultado final de este proyecto no debe ser únicamente una biblioteca, ya que por limitaciones de tiempo y alcance, no podemos pretender que esta biblioteca sea una solución completa y lista para usar en producción. Por ello, los objetivos de este trabajo son principalmente dos:

- *Un documento que recoja la investigación realizada a modo de tutorial*, explicando de forma intuitiva y detallada todos los pasos necesarios para implementar un prototipo de la solución propuesta. El documento debe explicar los conceptos clave, las decisiones de diseño y los mecanismos de integración utilizados en la solución propuesta.

- *El diseño e implementación de la biblioteca prototipo*, considerándose finalizada cuando se cumplan los requisitos elicitados y se demuestre su funcionamiento mediante un conjunto de aplicaciones de ejemplo. La implementación debe ser clara y modular, facilitando su comprensión, extensión y adaptación a diferentes contextos y necesidades.

== Estructura <structure>

Este documento está dividido en capítulos. Este capítulo inicial proporciona al lector el contexto necesario para el resto de capítulos con un breve resumen de la historia moderna del desarrollo web y el concepto de microfrontends, además de establecer los objetivos de este trabajo.

El @project-planning[capítulo] presenta el plan de proyecto, incluyendo la metodología usada durante la investigación y el desarrollo, así como la estimación y la planificación de tareas y costes.

El @project-analysis[capítulo] describirá de manera formal los actores y requisitos elicitados para el sistema final, considerándose este una biblioteca.

El @research-and-development[capítulo] se centra en la investigación, análisis y desarrollo de la implementación de App Federation, funcionando como un tutorial que explica de forma intuitiva todos los conceptos alrededor de los microfrontends y cómo aparecen las necesidades que la biblioteca debe cubrir.

El @user-guide[capítulo] proporciona una guía para los desarrolladores que pretendan usar el producto de este trabajo en su organización, ya sea de forma directa o extendiendo la biblioteca. Además, se hace un pequeño tour por un conjunto de aplicaciones anfitrionas y remotas que demuestran las capacidades de la biblioteca.

Finalmente, el @conclusions[capítulo] presenta las conclusiones de este trabajo y sugiere algunas ideas para futuros trabajos que lo extiendan.

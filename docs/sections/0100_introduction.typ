= Introducción <introduction>

== Motivación <motivation>

En los últimos veinticinco años, el ecosistema web ha experimentado cambios a un ritmo vertiginoso. Al inicio del siglo, los desarrolladores construían sitios mayoritariamente estáticos utilizando únicamente lenguajes de marcado como HTML y CSS. Los sitios dinámicos, que eran una minoría, usaban tecnologías del lado de servidor (como PHP, Java o ASP) que emitían el marcado. Esto relegaba JavaScript únicamente a pequeños scripts que mejoraban la experiencia de usuario o que introducían una solución alternativa a problemas que no podían solucionarse solo con lenguaje de marcado.

La evolución de JavaScript, la aparición de nuevos estándares web y su implementación en los navegadores han facilitado la creación de interfaces cada vez más complejas en el cliente. Un patrón habitual es la Single Page Application o SPA: una aplicación que carga un documento web y actualiza su contenido mediante JavaScript cuando cambia la vista, en lugar de cargar un documento nuevo en cada navegación @cite-mdn-spa.

Con la expansión de las SPA y la aparición de frameworks cada vez más potentes para el frontend, también crecieron las necesidades del proceso de construcción de aplicaciones web. Los bundlers analizan las dependencias de un proyecto y transforman su código y recursos para su distribución. Según la herramienta y su configuración, la salida puede consistir en uno o varios archivos optimizados e incluir minificación, eliminación de código no utilizado y división del código en partes que se cargan bajo demanda. Estas técnicas pueden reducir el código transferido inicialmente, aunque el resultado y su efecto en el rendimiento dependen de la aplicación y de la configuración @cite-webpack-code-splitting, @cite-webpack-tree-shaking.

En proyectos grandes, especialmente en organizaciones con varios equipos, mantener y evolucionar una aplicación frontend monolítica puede plantear desafíos de coordinación y despliegue. Los microfrontends son una de las alternativas propuestas: dividen la aplicación en partes que pueden ser desarrolladas y desplegadas de manera independiente y luego integradas en un producto común. Este enfoque puede aportar autonomía a los equipos, pero también introduce costes y complejidad que deben valorarse según el contexto @cite-fowler-microfrontends, @cite-peltonen-microfrontends-review, @cite-andalucia-microfrontends.

En ocasiones, estas implementaciones introducen funcionalidades que resultan indeseables o, de forma opuesta, omiten funcionalidad que resulta esencial.  Debido a su alta complejidad, estas implementaciones son difíciles de estudiar y modificar para los propósitos específicos de cada organización particular, por lo que fallan en ofrecer una solución completa o extensible.

== State-of-the-art <state-of-the-art>

Existen muchos tipos de implementaciones de microfrontends. En este trabajo las dividiremos de acuerdo a tres categorías que se corresponden, principalmente, con su forma de uso, su funcionamiento interno y el momento en el que llevan a cabo la mayor parte del trabajo:

- *Paradigma*: existen implementaciones que requieren registrar los microfrontends en la aplicación padre de forma *declarativa*, mientras que otros permiten cargar microfrontends de forma completamente *programática*, sin necesidad de registro previo o metadatos más allá de la dirección web donde reside el punto de entrada (como veremos en el @managing-execution[capítulo])

- *Aislamiento*: mientras que algunas implementaciones comparten el mismo entorno entre aplicaciones padre e hijas (*cooperativas*), otras garantizan el aislamiento de los microfrontends utilizando técnicas avanzadas de aislamiento como la interpretación de JavaScript embebida (*sandboxed*).

- *Tiempo de ejecución*: una implementación puede ser completamente agnóstica con respecto a las herramientas de compilación (bundlers) y funcionar sin modificar los microfrontends en absoluto (en cuyo caso diríamos que es una implementación en *run-time*), o pueden requerir modificar la compilación de los microfrontends para añadir parte o la totalidad de la funcionalidad (*build-time*).

Debido a la fragmentación del ecosistema, es difícil encontrar una lista exhaustiva de las implementaciones existentes y no se han encontrado datos claros sobre su cuota de mercado. Por ello, este análisis compara seis implementaciones seleccionadas para ilustrar distintos enfoques: Module Federation, single-spa, qiankun, Native Federation, Garfish y micro-app @cite-module-federation-runtime, @cite-single-spa-api, @cite-qiankun-migration, @cite-native-federation-runtime, @cite-garfish, @cite-micro-app. De acuerdo a la clasificación anterior, se organizan de la siguiente manera:

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
)

Implementaciones declarativas como single-spa suelen organizar el registro de aplicaciones usando una configuración global que especifica cuándo debe activarse cada microfrontend @cite-single-spa-api. Este enfoque puede ser útil para mantener una estructura fija, pero también puede limitar la flexibilidad cuando la organización necesita descubrir aplicaciones dinámicamente.

Module Federation y Native Federation son semideclarativas: aunque es común registrar microfrontends mediante configuración o manifiestos, sus runtimes también ofrecen mecanismos para registrar y cargar módulos de forma dinámica @cite-module-federation-runtime, @cite-native-federation-runtime. A la vez, son implementaciones cooperativas y basadas en el tiempo de compilación, lo que las convierte en dos de las opciones más dinámicas de la lista. Sin embargo, presentan algunos problemas: no soportan la creación de múltiples instancias de un mismo microfrontend, y tampoco proporcionan al usuario funcionalidades importantes como el aislamiento de estilos, requiriendo que el usuario implemente su propia solución @cite-mf-style-isolation.

Por otro lado, las soluciones como qiankun, Garfish o micro-app no requieren ninguna registro de antemano ni modificación en el proceso de compilación de los microfrontends y únicamente requieren mínimos cambios en run-time. Este paradigma conlleva el uso de sandboxing, dado que las aplicaciones hijas no cooperan de ninguna forma con la aplicación padre y, por tanto, es necesario aislarlas del entorno de forma estricta. Aunque esto ayuda a conseguir una separación de responsabilidades estricta y previene que los errores se propaguen de hijos a padres o viceversa, también introduce un mecanismo muy complejo y pesado que, además de introducir posibles bugs, puede reducir el rendimiento o aumentar el tamaño final del bundle.

== Objetivos <goals>

En vista de la clasificación anterior y de la complejidad de todas las soluciones analizadas, este documento propone estudiar, definir e implementar una solución académica de microfrontends, manteniendo la simplicidad para su estudio y extensión posterior, tanto por futuras investigaciones como para cubrir necesidades específicas de las organizaciones que decidan usarla como base para sus propias soluciones.

Teniendo esto en cuenta, nuestra visión de App Federation como una biblioteca de microfrontends responde a las siguientes características:
- *Programática*: Por diseño, no requerirá ningún tipo de configuración previa para cargar dinámica de microfrontends.
- *Cooperativa*: Evita la introducción de mecanismos complejos que inducen a errores como el sandboxing, además de facilitar la comunicación entre microfrontends al permitir el paso de variables, punteros y en general cualquier tipo de objeto de JavaScript entre ellos.
- *Build-time*: Dado que necesitamos cooperación entre los microfrontends, será necesario añadir lógica adicional en la compilación del mismo, aunque esta lógica siempre será lo más transparente posible para el usuario y se evitará cualquier comportamiento que aparezca como consecuencia indirecta de estas modificaciones.

No obstante, el resultado final de este proyecto no debe ser únicamente una biblioteca, ya que por limitaciones de tiempo y alcance, no podemos pretender que esta biblioteca sea una solución completa y lista para usar en producción. Por ello, los objetivos de este trabajo son principalmente dos:

- *Un documento que recoja la investigación realizada a forma de tutorial*, explicando de forma intuitiva y detallada todos los pasos necesarios para implementar un prototipo de la solución propuesta.

- *El diseño e implementación de la biblioteca prototipo*, considerandose finalizada cuando se cumplan los requisitos elicitados y se demuestre su funcionamiento mediante un conjunto de aplicaciones de ejemplo.

== Estructura <structure>

Este documento está divido en capítulos. Este capítulo inicial proporciona al lector el contexto necesario para el resto de capítulos con un breve resumen de la historia moderna del desarrollo web y el concepto de microfrontends, además de establecer los objetivos de este trabajo.

El @project-planning[capítulo] presenta el plan de proyecto, incluyendo la metodología usada durante la investigación y el desarrollo, así como la estimación y la planificación de tareas y costes.

El @project-analysis[capítulo] describirá de manera formal los actores y requisitos elicitados para el sistema final, considerándose este una biblioteca.

El @research-and-development[capítulo] se centra en la investigación, análisis y desarrollo de la implementación de App Federation, funcionando como un tutorial que explica de forma intuitiva todos los conceptos alrededor de los microfrontends y cómo aparecen las necesidades que la biblioteca debe cubrir.

El @user-guide[capítulo] proporciona una guía para los desarrolladores que pretendan usar el producto de este trabajo en su organización, ya sea de forma directa o extendiendo la biblioteca. Además, se hace un pequeño tour por un conjunto de aplicaciones padre-hijo que demuestran las capacidades de la biblioteca.

Finalmente, el @conclusions[capítulo] presenta las conclusiones de este trabajo y sugiere algunas ideas para futuros trabajos que lo extiendan.

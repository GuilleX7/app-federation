= Introducción <introduction>

== Motivación <motivation>

En los últimos veinticinco años, el ecosistema web ha experimentado cambios a un ritmo vertiginoso. Al inicio del siglo, los desarrolladores construían sitios mayoritariamente estáticos utilizando únicamente lenguajes de marcado como HTML y CSS. Los sitios dinámicos, que eran una minoría, usaban tecnologías del lado de servidor (como PHP, Java o ASP) que emitían el marcado. Esto relegaba JavaScript únicamente a pequeños scripts que mejoraban la experiencia de usuario o que introducían una solución alternativa a problemas que no podían solucionarse solo con lenguaje de marcado.

La evolución de JavaScript como lenguaje de programación, la aparición de nuevos estándares web han transformado y la implementación de éstos en los navegadores web ha fomentado cada vez más el uso de JavaScript no solo como un lenguaje de scripting, sino como un lenguaje de programación completo. Así, a principios de la década de 2010, comenzaron a aparecer bibliotecas como AngularJS, Backbone o Ember, que introdujeron el concepto de Single Page Application o SPA. Este paradigma permite crear aplicaciones web utilizando principalmente JavaScript, aumentando la separación de responsabilidades entre el frontend y el backend @cite-wiki-spa.

Con la solidificación de las SPA como paradigma y la aparición de frameworks cada vez más potentes para el frontend (como React o Vue), el proceso de construcción de aplicaciones web se fue volviendo cada vez más complejo, favoreciendo la aparición de herramientas que ayudaran a construir y mantener estas aplicaciones. Es así como nacen los bundlers, herramientas análogas a los compiladores en el desarrollo web que permiten tomar diferentes bibliotecas, frameworks, módulos de JavaScript y otros recursos (como imágenes, estilos, etc.) y combinarlos en un único archivo (o bundle) optimizado, tanto en espacio como en velocidad, para su uso en producción.

El gran éxito cosechado por el paradigma SPA y el uso de bundlers ha perdurado hasta nuestros días, donde la mayoría de aplicaciones web se siguen desarrollando con este enfoque. No obstante, la inmutabilidad de los bundles y la aparición de proyectos cada vez más grandes y complejos, especialmente en grandes organizaciones, han llevado a la necesidad de buscar alternativas más flexibles y escalables. Así, en grandes desarrollos, el enfoque ha evolucionado hacia modelos más distribuidos y modulares, como los microfrontends. Este busca resolver los desafíos de escalabilidad, mantenibilidad y autonomía que presentan los monolitos tradicionales, permitiendo que diferentes equipos desarrollen, desplieguen y mantengan aplicaciones independientes que se integran de forma coordinada @cite-andalucia-microfrontends.

En ocasiones, estas implementaciones introducen funcionalidades que resultan indeseables o, de forma opuesta, omiten funcionalidad que resulta esencial.  Debido a su alta complejidad, estas implementaciones son difíciles de estudiar y modificar para los propósitos específicos de cada organización particular, por lo que fallan en ofrecer una solución completa o extensible.

== State-of-the-art <state-of-the-art>

Existen muchos tipos de implementaciones de microfrontends. En este trabajo las divideremos de acuerdo a tres categorías que se corresponden, principalmente, con su forma de uso, su funcionamiento interno y el momento en el que llevan a cabo la mayor parte del trabajo:

- *Paradigma*: existen implementaciones que requieren registrar los microfrontends en la aplicación padre de forma *declarativa*, mientras que otros permiten cargar microfrontends de forma completamente *programática*, sin necesidad de registro previo o metadatos más allá de la dirección web donde reside el punto de entrada (como veremos en el @managing-execution[capítulo])

- *Aislamiento*: mientras que algunas implementaciones comparten el mismo entorno entre aplicaciones padre e hijas (*cooperativas*), otras garantizan el aislamiento de los microfrontends utilizando técnicas avanzadas de aislamiento como la interpretación de JavaScript embebida (*sandboxed*).

- *Tiempo de ejecución*: una implementación puede ser completamente agnóstica con respecto a las herramientas de compilación (bundlers) y funcionar sin modificar los microfrontends en absoluto (en cuyo caso diríamos que es una implementación en *run-time*), o pueden requerir modificar la compilación de los microfrontends para añadir parte o la totalidad de la funcionalidad (*build-time*).

Debido a la alta fragmentación del ecosistema, es difícil encontrar una lista exhaustiva de las diferentes implementaciones existentes. Además, no se han podido encontrar datos claros sobre la cuota de mercado de la mayoría de implementaciones. Sin embargo, el conjunto de búsquedas realizado a través de Google arroja cinco implementaciones prominentes: Module Federation, single-spa, qiankun, Nativa Federation, Garfish o micro-app. De acuerdo a nuestra clasificación anterior, podemos organizarlas de la siguiente manera:

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

Como podemos observar, las dos implementaciones más relevantes de la actualidad son cooperativas. Sin embargo, single-spa sigue una estructura declarativa: requiere que las aplicaciones padres registren un manifiesto donde se definen todas aquellas aplicaciones hijas que podrán ser cargadas en run-time. Este enfoque dogmático puede ser útil para mantener una estructura fija, pero también obliga a cambiar de forma drástica cómo las aplicaciones están organizadas en la organización y puede limitar la libertad cuando los usuarios tienen otras necesidades.

Module Federation y su descendiente, Native Federation, son dos implementaciones semideclarativas, esto es, aunque es común usar manifiestos en tiempo de compilación donde los microfrontends quedan registrados, estas implementaciones también permiten registrarlos en tiempo de ejecución. A la vez, son implementaciones cooperativas y basadas en el tiempo de compilación, lo que las convierte en dos de las opciones más dinámicas de la lista. Sin embargo, presentan algunos problemas: no soportan la creación de múltiples instancias de un mismo microfrontend, y tampoco proporcionan al usuario funcionalidades importantes como el aislamiento de estilos, requiriendo que el usuario implemente su propia solución. @cite-mf-style-isolation

Por otro lado, las soluciones como qiankun, Garfish o micro-app no requieren ninguna modificación en el proceso de compilación de los microfrontends y únicamente requieren mínimos cambios en run-time. Este paradigma conlleva el uso de sandboxing, dado que las aplicaciones hijas no cooperan de ninguna forma con la aplicación padre y, por tanto, es necesario aislarlas del entorno de forma estricta. Aunque esto ayuda a conseguir una separación de responsabilidades estricta y previene que los errores se propaguen de hijos a padres o viceversa, también introduce un mecanismo muy complejo y pesado que, además de introducir posibles bugs, puede reducir el rendimiento, aumentar el tamaño final del bundle y resultar innecesario para los requisitos de otras organizaciones.

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

#import "../themes/content.typ": content-theme
#import "@preview/zero:0.7.1": num

#show: content-theme

= Conclusiones <conclusions>

Por un lado, hemos descrito de forma rigurosa cómo debe comportarse una implementación de microfrontends que siga la especificación dada por App Federation. Así, hemos obtenido un documento que sirve tanto de especificación de la arquitectura como de tutorial para el desarrollo de futuras implementaciones que extiendan esta arquitectura.

Por otro lado, y siguiendo los ejemplos incrementales desarrollados en el ámbito del @research-and-development[capítulo], podemos tomar como artefacto final la biblioteca usada en el último ejemplo, pues cumple todos los requisitos elicitados en el @project-analysis[capítulo]. El resultado es una biblioteca escrita en TypeScript sin dependencias y lista para ser usada en cualquier proyecto web.

Si bien la biblioteca no proporciona el nivel de sofisticación y las funcionalidades que otras implementaciones existentes ya incorporan, como las mencionadas en la @state-of-the-art[sección], cumple con el objetivo de ser un prototipo de referencia de la arquitectura de microfrontends propuesta, además de ser ligera (alrededor de #num(1500) líneas de código fuente) y extensible, pues la mayoría de funcionalidades están implementadas de forma modular, como la comunicación entre microfrontends.

== Trabajo futuro

Aunque damos por concluido el trabajo, existe una serie de funcionalidades que no han podido implementarse por limitaciones de tiempo y esfuerzo.

- *Soporte para otros bundlers.* Debido a las limitaciones, el plugin desarrollado únicamente soporta Rspack. Dado que Rspack usa un runtime compatible con webpack, desarrollar un plugin para webpack u otros bundlers derivados de él no debería resultar difícil. Por otro lado, bundlers como Vite o esbuild difieren en runtime y arquitectura, por lo que sería necesario llevar a cabo una investigación más detallada de su funcionamiento.

- *Aislamiento en tiempo de compilación.* Como vimos en la @1-microfrontend-comparison[tabla], algunas de las implementaciones actuales soportan aislamiento en tiempo de ejecución. Sin embargo, esto introduce mecanismos complejos y aumenta la probabilidad de encontrar bugs. Una vía de investigación futura consistiría en estudiar posibles mecanismos de aislamiento en tiempo de compilación, esto es, analizar el código fuente y modificarlo para evitar que un microfrontend pueda afectar al entorno global, ya sea de forma total o parcial, y que el usuario pueda controlar el alcance de este aislamiento.

- *Compartición de dependencias.* Esta es una característica popular que otras implementaciones de microfrontends comparten. Sin embargo, debido a la dificultad de implementación y dado que se trata de una técnica de optimización, ha sido relegada a una posible línea de investigación futura. En teoría, un microfrontend debería ser capaz de compartir bibliotecas a través de fábricas, como vimos en el @instance-factory[capítulo], permitiendo así que cada microfrontend mantenga su propia instancia de la dependencia. También sería interesante permitir la reutilización de la misma instancia si dos microfrontends deciden compartirla.

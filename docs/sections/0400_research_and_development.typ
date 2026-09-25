// LTeX: language=es-ES

#import "@preview/codly:1.3.0": *

= Investigación y desarrollo <research-and-development>

En este capítulo abordaremos la investigación realizada para llevar a cabo el desarrollo e implementación de la librería prototipo. Dado que se trata de un proyecto con carácter teórico-práctico, se intercalarán explicaciones teóricas con fragmentos de código provenientes de los ejemplos desarrollados.

El primer apartado servirá como una pequeña introducción al funcionamiento de los bundlers, que usaremos de forma extensa para el trabajo. El resto de subcapítulos abordará cada uno de los aspectos fundamentales de la solución, como la carga e inyección de microfrontends, la inyección de estilos y la intercomunicación entre microfrontends.

#include "0410_rnd_why_using_a_bundler.typ"
#include "0420_rnd_microfrontend_dynamic_loading.typ"

== Estilos en microfrontends <microfrontend-styles>

=== Inyección rudimentaria inicial
=== Delimitando estilos: _shadow root_
=== Peculiaridades del _shadow root_

== Estado y acciones en microfrontends <microfrontend-state-and-actions>

=== Estado local: padre e hijo
=== Estado global: buses
=== Ejemplo: _routing_

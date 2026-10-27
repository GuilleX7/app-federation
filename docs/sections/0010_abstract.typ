#import "../themes/preface.typ": preface-theme
#import "../utils/constants.typ": *

#show: preface-theme

#set heading(outlined: false, bookmarked: true)

= Resumen

App Federation es una biblioteca basada en Module Federation e implementa, mediante un enfoque programático, la carga dinámica de microfrontends y la comunicación entre ellos. App Federation abstrae los detalles de implementación e incorpora la separación de responsabilidades como principio fundamental, permitiendo que los microfrontends se instancien dinámicamente, mantengan instancias independientes y se integren sin problemas en tiempo de ejecución. La biblioteca introduce un modelo de estado compartido y ejecución de acciones que permite la colaboración entre microfrontends sin sacrificar su autonomía, mejorando la escalabilidad, mantenibilidad y experiencia de desarrollo en arquitecturas frontend distribuidas, habituales en grandes organizaciones.

Este documento detalla la arquitectura, los principios de diseño y las funcionalidades clave de App Federation, proporcionando una guía completa para su implementación y uso en proyectos de microfrontends. A su vez, este documento sirve como referencia para el aprendizaje y comprensión de los conceptos fundamentales relacionados con las arquitecturas basadas en microfrontends, exponiendo los problemas comunes y guiando al lector a través de las soluciones aplicadas.

Palabras clave: #doc.keywords.es.map(keyword => emph(keyword)).join([, ])

= Abstract

App Federation is a library based on Module Federation that uses a programmatic approach to load microfrontends dynamically and enable communication between them. App Federation abstracts implementation details and incorporates separation of concerns as a core principle, enabling microfrontends to be dynamically instantiated, maintain independent instances, and be seamlessly integrated at runtime. The library introduces a shared state and action execution model that enables collaboration between microfrontends without sacrificing their autonomy, improving scalability, maintainability, and the developer experience in distributed frontend architectures, which are common in large organizations.

This document details the architecture, design principles, and key features of App Federation, providing a comprehensive guide for its implementation and use in microfrontend projects. Additionally, this document serves as a reference for learning and understanding the fundamental concepts related to microfrontend-based architectures, exposing common problems and guiding the reader through the applied solutions.

Keywords: #doc.keywords.en.map(keyword => emph(keyword)).join([, ])

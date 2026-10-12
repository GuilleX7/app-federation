#set document(
  title: "App Federation: un enfoque programático para la integración de microfrontends basado en Module Federation",
  author: "Guillermo Diz Gil",
  description: "App Federation es una biblioteca diseñada para extender Module Federation e implementar, mediante un enfoque programático, la carga dinámica de microfrontends y la comunicación entre ellos. App Federation abstrae los detalles de implementación e incorpora la separación de responsabilidades como principio fundamental, permitiendo que los microfrontends se instancien dinámicamente, mantengan instancias independientes y se integren sin problemas en tiempo de ejecución. La biblioteca introduce un modelo de estado compartido y ejecución de acciones que permite la colaboración entre microfrontends sin sacrificar su autonomía, mejorando la escalabilidad, mantenibilidad y experiencia de desarrollo en arquitecturas frontend distribuidas, habituales en grandes organizaciones.",
  keywords: (
    "microfrontends",
    "Module Federation",
    "carga dinámica",
    "dynamic loading",
    "integración en tiempo de ejecución",
    "runtime integration",
    "aislamiento de estilos",
    "style isolation",
    "comunicación entre microfrontends",
    "microfrontend communication",
  ),
)

#import "themes/global.typ": global-theme
#import "themes/preface.typ": preface-theme
#import "themes/content.typ": content-theme
#import "themes/postface.typ": postface-theme

#import "utils/specialWords.typ": specialWords

#show: global-theme

#include "sections/0000_frontpage.typ"

#preface-theme[
  #include "sections/0001_abstract.typ"
  #include "sections/0002_acknowledgements.typ"
  #include "sections/0003_outlines.typ"
]

#content-theme[
  // #show: specialWords

  #include "sections/0100_introduction.typ"
  #include "sections/0200_project_plan.typ"
  #include "sections/0300_project_analysis.typ"
  #include "sections/0400_research_and_development.typ"
  // #include "sections/0500_user_guide.typ"
  #include "sections/0600_conclusions.typ"
]

#postface-theme[
  #include "sections/9999_bibliography.typ"
]

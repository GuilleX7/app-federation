// LTeX: enabled=false

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
  #show: specialWords
  
  #include "sections/0100_introduction.typ"
  #include "sections/0200_project_plan.typ"
  #include "sections/0300_project_analysis.typ"
  #include "sections/0400_research_and_development.typ"
  #include "sections/0500_user_guide.typ"
  #include "sections/0600_conclusions.typ"
]

#postface-theme[
  #include "sections/9999_bibliography.typ"
]

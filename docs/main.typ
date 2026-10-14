#import "themes/global.typ": global-theme
#import "themes/preface.typ": preface-theme
#import "themes/content.typ": content-theme
#import "themes/postface.typ": postface-theme

#import "utils/constants.typ": doc
#import "utils/specialWords.typ": specialWords

#set document(
  title: doc.title,
  description: doc.description.es,
  author: doc.author,
  keywords: (..doc.keywords.es, ..doc.keywords.en).dedup(),
)

#show: global-theme

#include "sections/0000_frontpage.typ"

#preface-theme[
  #include "sections/0010_abstract.typ"
  // #include "sections/0020_acknowledgements.typ"
  #include "sections/0030_ai_disclaimer.typ"
  #include "sections/0040_outlines.typ"
]

#content-theme[
  // #show: specialWords

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

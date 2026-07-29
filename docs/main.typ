#import "themes/global.typ": global-theme
#import "themes/preface.typ": preface-theme
#import "themes/content.typ": content-theme
#import "themes/postface.typ": postface-theme

#show: global-theme

#include "sections/0000_frontpage.typ"

#preface-theme[
  #include "sections/0001_abstract.typ"
  #include "sections/0002_acknowledgements.typ"
  #include "sections/0003_outlines.typ"
]

#content-theme[
  #include "sections/0100_introduction.typ"
]

#postface-theme[
  #include "sections/9999_bibliography.typ"
]
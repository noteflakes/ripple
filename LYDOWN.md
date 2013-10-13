# Lydown: markup language for musical notation
# 
# Translates to lilypond syntax.
# 
# - no curly braces
# - multiple sections in a single file
# - metadata mixed with data
# - lyrics/figures in same file with notes

# this is a comment

# score configuration
score: {Violino I, Violino II}, Faggott, {Soprano, Alto, Tenore, Basso}, Continuo
parts: Violino I, Violino II, Faggott, Continuo

Soprano # this is a section header
==================================
relative:c' clef:g time:4/4 key:g % clef, meter, key definitions
_4g'(ab8)c
b(a16g)d'4~(d16f-ed)(cbab)
(cedc)(bcde)a,4_8d
bdgfed16c+d4.|
 g,f/~/(e6d)d4_ # _ means rest?
 
# note regexp
#   parens   note       accidentals      octave   value      dot       expression            parens
# /([\(\[]*)([a-g_rR])?([\-\+@]*)([\!\?])?([',]*)([0-9\*\/]*)([\.]+\|?)?((\/[^\/\s][\/\s])*)([\)\]]*)/

# triplets
g8*2/3ag # like lilypond
# or:
g8`ag # like ripple
 
# check bar number checking
1: abcdefg

# pitch classes
cdefgabrR

# pitches are always relative to key signature
# e.g. key:g => f sharp, key:gm => b flat, e flat

# accidentals
b+b@b # accidentals are valid until next accidental or end of line
  + => sharpen relative to key signature
  - => flatten relative to key signature
  @ => back to default (from key signature)
  ++ => double sharpen
  -- => fouble flatten
  ? => cautionary accidental (with parens)
  ! => force show accidental
  
b+bb@bb!
  
# rhythms
c1c2c4c8c6c3
c4.d8 # dotted
c4..d6 # double-dotted
c4.| # dotted over bar line
c4~c8 # tied
c4~8 # tied with note name omitted

# expressive marks
c/. # staccato
c/' # marcato (or whatever the hell)
c/forte/d # separated by slash
c/piano d #   or by whitespace
c/~ # trill
c/. # mordent
c/- # tenuto
c/^ # hat
c/"custom text" # above staff
c\"custom text" # below staff
c/"_custom text_" # italic (markdown-style)
# etc... (add more by )

Soprano:lyrics
==============
O heil'--ges Geist\- und Was----ser-bad,
daß...

Continuo:figures
================


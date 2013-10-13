# Lilypond Syntax Extensions

In order to use the following syntax extensions, you need to use the .rpl filename extension. 

## Include files

Include files can be put in an <code>_includes</code> directory under your main project directory, e.g.:

    my_music
      _includes
        lib.ly
        part.ly
        score.ly

Those files can be used to define Lilypond macros. For example see [here](https://github.com/ciconia/music/tree/master/_include).

<code>_includes/part.ly</code> will only be included for parts. Likewise, <code>_includes/score.ly</code> will only be included for scores.

## Context-specific code

You can make code be included in scores only by placing it inside double curly brackets:

    {{\break}}

Code to appear only for parts should be placed inside double square brackets:

    [[\break]]

Code for producing MIDI should be placed inside double curly brackets prefixed with <code>m</code>:

    m{{\tempo 4 = 78}}

A more useful example, out of BWV 236 (add a _Volti Subito_ and page break in the part):

    {{r}} [[r_\markup { \italic "V.S." } \break]]

## Shorthand for sharps and flats

Sharps:

    cs css ds dss es => cis cisis dis disis eis
    
Flats:

    cb cbb db dbb eb => ces ceses des deses ees
    
## Prefixed slurs and beams for better readability

    (a8 [b c d]) ([d8 f] c4) => a8( b[ c d]) d8([ f] c4)

## Shorthand for 16th, 32nd notes

    c6 d3 => c16 d32
    
## Shorthand for 2/3 value (triplets)

Handy for writing unobtrusive triplets.

    f8 ~ ([f6` e]) f => f8 ~ f16*2/3([ e]) f
    
## Cross-bar dotting

Very useful for baroque music. This shorthand notation gets converted into quite an elaborate piece of code.

    c2 d2.| e4 f g =>
    c2 \\once \\override Tie #'transparent = ##t d2 ~ \\once \\override NoteHead #'transparent = ##t \\once \\override Dots #'extra-offset = #'(-1.3 . 0) \\once \\override Stem #'transparent = ##t d2.*0 s4 e4 f g

## Shorthand for appogiatura

    ^e8 d4 => \appoggiatura e8 d4
    
## Shorthand for cue voices

These will appear only in parts.

    a ![[b c]] => a \new CueVoice { b c }
    
## Shorthand for divisi

    /1 a4 /2 b4 /u c2 => << { \voiceOne a4 } \new Voice { \voiceTwo b4 } >> \oneVoice c2
    
***

## Macros

Macros are used for repeating rhythms and/or articulation. A macro section begins with <code>$</code> and ends with <code>$$</code>. Ad-hoc macros can be created by using <code>$!</code> followed by the macro definition (with <code>#</code> as a place holder for notes), followed by <code>$</code>:

    $!(#8. #6)$ g g g g g g $$ c,4 => g8.( g16) g8.( g16) g8.( g16) c,4

Macros can also be predefined in the macros section of the _work.yml or any other configuration files:

    macros:
      8.6: (#8. #6)
      
The predefined macros can be used as follows:

    $8.6 g g g g $$ => g8.( g16) g8.( g16)
    
Notes can be repeated by using <code>@</code> as a placeholder:

    $!#8. @6 #8$ g e g e $$ => g8. g16 e8 g8. g16 e8
    
***

## Alternative Syntax for Basso Continuo Figures

The stock Lilypond syntax for *basso continuo* figures is far from ideal. Ripple offers a better solution that is easier to read and much faster to write. To use this syntax the figures file should have the <code>.fig</code> extension.

Each chord consists of one or more figures, optionally followed by a slash and a duration value. The format pretty much explains itself. Here is an excerpt from BWV 135/1:

    #/2.
    ,/2 642/4
    65 642 5/8 6\
    54/4 _3 6/8 5
    7#/4 642' 75#
    65# _4 5#
    64 7\42'/2
    85#/2.
    ,/2.*4
    6\/2.
    6
    7/4 6/2
    7#/4 64 5#
    65#/8 _4 5#/4 64
    642 7\42/2
    853/2.

Rest/silence is notated by <code>s</code> or alternatively <code>,<code>. Here's a quick cheatsheet:
  
    # => 3+
    b => 3-
    h => 3!

    comment : % blah blah
    duration: /2. /4 /2.*4 etc
    silence : s , ,/2
    chord   : 65 65/2
    sharp   : 6+ 6+5 6++
    flat    : 6- 6-5- 3--
    natural : 6! 5!
    altered : 6` 4'
    tenue   : 65 _4
    
***

## Alternative Syntax for Lyrics

Ripple also offers a better syntax for lyrics. Files using this syntax should use the <code>.lyr</code> extension:

    Je-su mei-ne Freu--de, => Je -- su mei -- ne Freu -- _ de, 
    
A dash in the text should be escaped with a backslash:
    
    O heil'-ges geist\-_ und Was----ser-bad__ =>
      O heil' -- ges geist- __  und Was -- _ _ _ ser -- bad __ _
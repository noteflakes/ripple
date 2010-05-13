# Ripple - DRY for Lilypond

Ripple is a small program that helps you generate scores and parts without repeating yourself, performing complex includes or writing scheme macros.

Ripple does two things:

- Put together scores and parts from files organized in a specific directory hierarchy.
- Allow you to use a better syntax for writing music, with support for macros (very useful for notating recurring rhythms), better accidentals, prefixed beams and slurs, and shorthand notation for stuff like divisi, appogiaturas, etc.

For comprehensive examples of usage checkout out my [music scores project](http://github.com/ciconia/music/tree) (mainly Bach stuff).

## A Ripple project:

Ripple expects your files to be organized a certain way for it to function correctly. Here is a simple example:

    my_music
      bach
        BWV1027-1
          _work.yml
          gamba.rpl
          cembalo.rpl

The music is contained in <code>.ly</code> or <code>.rpl</code> files (the latter are assumed to be in Ripple syntax and are converted to normal Lilypond syntax). The <code>\_work.yml</code> file is a YAML file that contains the attributes of the work (more about that later):

    title: Sonata for Viola da Gamba and Harpsichord G-dur BWV1027
    composer: Johann Sebastian Bach
    parts:
      gamba:
        title: Viola da gamba
    score:
      order: gamba, cembalo
      
To process the files into parts and scores, simply cd into the directory and run ripple.

    cd my_music
    ripple
    
Ripple will generate Lilypond files and put them into <code>my\_music/\_ly</code>, and then run Lilypond to produce PDF files that will be put in <code>my\_music/\_pdf</code>.

## Multi-movement works

Ripple also supports multi-movement works. Consider the following file hierarchy:

    my_music
      BWV1029
        _work.yml
        01-allegro
          gamba.rpl
          cembalo.rpl
        02-adagio
          gamba.rpl
          cembalo.rpl
        03-vivace
          gamba.rpl
          cembalo.rpl

Ripple will generate gamba and cembalo parts containing all three movements, as well as a score containing the three movements. The directory names are converted into movement titles, e.g. "1. Allegro", "2. Adagio" and "3. Vivace".

## Configuration files

Each work should have its own <code>\_work.yml</code> file. This file can be used to configure the different parts and their order in the score. Here is a sample file:

    title: Missa Brevis G-dur BWV 236
    composer: Johann Sebastian Bach
    editor: Sharon Rosner
    copyright: © IBS 2009 - all rights reserved
    score:
      hide_empty_staves: true
      order:
        - oboe1
        - oboe2
        - violino1
        - violino2
        - viola
        - soprano
        - alto
        - tenore
        - basso
        - continuo

Each movement can also have its own <code>\_movement.yml</code> file containing overrides for the specific movement. You can for example specify colla parte without copying the music:

    parts:
      oboe1:
        source: soprano
      oboe2:
        source: alto
      violino1:
        source: soprano
      violino2: 
        source: alto
      viola:
        source: tenore

This configuration file specifies that the oboe1 and violino1 parts take their music from the soprano part, oboe2 and violino2 from the alto part, and the viola from the tenore part.

In addition, default settings can be stored in a <code>_ripple.yml</code> file, which can be used for setting for example the editor's name or the copyright notice.

Ripple also currently includes the following default settings for several voice types and instruments:

1. Clef - the clef is automatically inserted by Ripple unless it is set to <code>none</code>.
2. AutoBeam:false/true (default is true) - this setting is can be used in order to insert a <code>\autoBeamOff</code> macro in vocal parts.

## Overriding default settings

The settings used by Ripple to process the source files are merged from the different settings files (<code>ripple/lib/defaults.yml</code>, <code>_ripple.yml</code>, <code>_work.yml</code>, <code>_movement.yml</code>) and can further be overriden by supplying an <code>--opt</code> option to the command-line tool.

    ripple BWV17 --opt "editor:Someone else but me"
    
# Auto-regeneration mode

Ripple can be put into auto-regeneration mode, in which it watches the source directory and process the specified files each time a file is saved in that directory. To use ripple in auto-regenration mode, add <code>auto:true</code> to your <code>_ripple.yml</code> file, or specify the <code>--auto</code> option for the command-line tool.

    ripple BWV17 --auto

# Proof mode

Proof mode is similar to auto-regeneration mode, except that each time a file is changed or added, it is compiled into PDF (as a single movement and part) and opened in the background. This mode is very useful when entering parts. To use ripple in proof mode, add <code>proof:true</code> to your <code>_ripple.yml</code> file, or specify the <code>--proof</code> or <code>-P</code> option for the command-line tool.
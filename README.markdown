# Ripple - DRY for Lilypond

Ripple is a small program that helps you generate scores and parts without repeating yourself, performing complex includes or writing scheme macros.

Here are some of Ripple's features:

- Create scores and parts from files organized in a consistent, easy-to-understand directory hierarchy.
- [Improved Lilypond syntax](https://github.com/ciconia/ripple/wiki) for writing music, with support for macros (very useful for notating recurring rhythms), better accidentals, prefixed beams and slurs, and shorthand notation for stuff like divisi, appogiaturas, etc.
- Automatically create MIDI versions of your scores.
- Proof mode for faster editing - get your PDF regenerated every time you save your source.
- Compilation mode for mixing different musical works together in a single score or part.

More information about the syntax extensions can be found on the [project wiki](https://github.com/ciconia/ripple/wiki). For comprehensive examples of the improved syntax checkout out my [music scores project](http://github.com/ciconia/music/tree) (mainly works by Bach).

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

The settings used by Ripple to process the source files are merged from the different settings files (<code>ripple/lib/defaults.yml</code>, <code>_ripple.yml</code>, <code>_work.yml</code>, <code>_movement.yml</code>) and can further be overriden by specifying an <code>--opt</code> switch:

    ripple BWV17 --opt "editor:Someone else but me"
    
# Auto-regeneration mode

Ripple can be put into auto-regeneration mode, in which it watches the source directory and process the specified files each time a file is saved in that directory. To use ripple in auto-regenration mode, add <code>auto:true</code> to your <code>_ripple.yml</code> file, or specify the <code>--auto</code> switch:

    ripple BWV17 --auto

# Proof mode

Proof mode is similar to auto-regeneration mode, except that each time a file is changed or added, it is compiled into PDF (as a single movement and part) and opened in the background. This mode is very useful when entering parts. To use ripple in proof mode, add <code>proof:true</code> to your <code>_ripple.yml</code> file, or specify the <code>--proof</code> or <code>-P</code> switch:

    ripple BWV17 -P

# Compilation mode

Compilation mode allows you to compile different pieces/movements into a single score or part. The compilation settings are defined in a YAML file. Here's a simple example:

title: My First Ripple Compilation
subtitle: Just Testing
movements:
  - work: bach/BWV1041
    movement: 01-allegro
  - work: bach/BWV1066
    movement: "09-bourree-II"
    score_breaks: 2
    parts:
      ira:
        source: fagotto
        breaks: 1
parts:
  ira:
    source: continuo
    clef: bass
    hide_figures: true
    
In order to process the compilation, use the <code>-c</code> switch:

    ripple -c compilations/test
    
When no parts are specified, Ripple will process all parts specified in the compilation file. As the example above shows, you can also control page breaks for individual parts and for the score. For more examples of usage look at [my own compilations](http://github.com/ciconia/music/tree/master/compilations/).

## Ad-hoc compilations

Ripple also lets you perform ad-hoc compilations without preparing a compilation file by using the <code>-C</code> switch:

    ripple -C bach/BWV156 bach/BWV044 bach/BWV017
    
If no parts are specified, only the score will be prepared. You can also compile specific movements by specifying them using the format <code>work#movement</code>. Ripple will also understand movement numbers instead of complete movement references:

    ripple -C bach/BWV156#1 bach/BWV044#2
    
You can also specify a title for the compilation by including the <code>-t</code> switch:

    ripple -C -t "My own title" bach/BWV156#1 bach/BWV044#2

# More ripple tips

## Process multiple works

    ripple bach/BWV017 bach/BWV166

## Create a MIDI version of your score:

    ripple bach/BWV017 -M

## Open the rendered PDF file once it is ready:

    ripple bach/BWV017 -o
    
This also works for MIDI files:

    ripple bach/BWV017 -M -o
    
If you find yourself always using the <code>-o</code> switch, you can add the following setting to your <code>_ripple.yml</code> file instead:

    open_target: true
    
## Process only the score:

    ripple bach/BWV017 -s
    
## Process only the parts:
   
    ripple bach/BWV017 --no-score
    
## Process a specific part:

    ripple bach/BWV017 -p continuo
    ripple bach/BWV017 -p violino1,violino2
    
## Process a specific movement:

    ripple bach/BWV017 -m 01-coro
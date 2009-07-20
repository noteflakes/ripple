# Ripple - a Lilypond Score Generator

Ripple is a small program that helps you generate scores and parts without performing complex includes or writing lisp expressions.

Ripple does two things:
- Put together scores and parts from files in organized in a specific directory hierarchy.
- Allow you to use a somewhat better syntax for writing music (not done yet).

## A Ripple project:

Ripple expects your files to be organized a certain way for it to function correctly. Here is a simple example:

    my_music
      bach
        BWV1027-1
          _work.yml
          gamba.rpl
          cembalo.rpl

The music is contained in .rpl files. The <code>\_work.yml</code> file is a YAML file that contains the attributes of the work (more about that later):

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

Ripple will generate gamba and cembalo parts containing all three movements, as well as a score containing the three movements.

## Configuration files

Each work should have its own <code>\_work.yml</code> file. This file can be used to configure the different parts and their order in the score. Here is a sample file:

    title: Missa Brevis G-dur BWV 236
    composer: Johann Sebastian Bach
    editor: Sharon Rosner
    copyright: © IBS 2009 - all rights reserved
    parts:
      oboe1:
        clef: treble
      oboe2:
        clef: treble
      violino1:
        clef: treble
      violino2:
        clef: treble
      viola:
        clef: alto
      soprano:
        clef: treble
      alto:
        clef: alto
      tenore:
        clef: treble_8
      basso:
        clef: bass
      continuo:
        clef: bass
      violino:
        ignore: true
        title: "Violino I, II"
    score:
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

When clefs are defined for a part, Ripple automatically inserts a <code>\\clef</code> statement at the relevant places. This is particularly useful when you need different parts containing the same music to have different clefs (for example, alto clef for singers and treble clef for violins).

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


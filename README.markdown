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
          gamba.rly
          cembalo.rly
        BWV1029
          _work.yml
          01-allegro
            gamba.rly
            cembalo.rly
          02-adagio
            gamba.rly
            cembalo.rly
          03-vivace
            gamba.rly
            cembalo.rly

The music is contained in the .rly (Ripple - Lilypond) files. The _work.yml file is a YAML file that contains the attributes of the work:

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
    
Ripple will generate Lilypond files and put them into my_music/_ly, and then run Lilypond to produce PDF files that will be put in my_music/_pdf.


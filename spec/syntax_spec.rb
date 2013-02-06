require File.expand_path(File.join(File.dirname(__FILE__), './spec_helper'))

def cvt(input, mode = nil, config = {})
  Ripple::Syntax.cvt(input, mode, config)
end

describe "Syntax converter" do
  it "should correctly convert accidentals" do
    cvt('c cs d ds e es f fs g gs a as b bs').should ==
      'c cis d dis e eis f fis g gis a ais b bis'
      
    cvt('c cb d db e eb f fb g gb a ab b bb').should ==
      'c ces d des e ees f fes g ges a aes b bes'
      
    cvt('css d ebb').should ==
      'cisis d eeses'
      
    cvt('cs1 bb- es! ab(').should ==
      'cis1 bes- eis! aes('
  end
  
  it "should not convert accidentals inside quotes" do
    cvt('as as "assai"').should ==
      'ais ais "assai"'
  end
  
  it "should not convert non-note-name accidentals" do
    cvt('ab\espressivo').should == 'aes\espressivo'
  end
  
  it "should move prefixed [ to after note" do
    cvt('[a b c]').should ==
      'a[ b c]'

    cvt('[a,4 b c]').should ==
      'a,4[ b c]'

    cvt("a b c [d").should ==
      'a b c d['
  end
  
  it "should move prefixed ( to after note" do
    cvt('[a b c]').should ==
      'a[ b c]'

    cvt('[a,4 b c]').should ==
      'a,4[ b c]'

    cvt("a b c [d").should ==
      'a b c d['
      
    cvt("[r a b c]").should ==
      'r[ a b c]'

    cvt("[r. a b c]").should ==
      'r.[ a b c]'

    cvt("[r.. a b c]").should ==
      'r..[ a b c]'
  end
  
  it "should not convert postfixed [" do
    cvt('a[ b]').should ==
      'a[ b]'
  end
  
  it "should not convert postfixed (" do
    cvt('a( b)').should ==
      'a( b)'
  end
  
  it "should convert 3,6 values to 32, 16 values" do
    cvt('a3 b6 b,,3 e6(').should ==
      'a32 b16 b,,32 e16('
      
    cvt('r6 b3 [a6').should ==
      'r16 b32 a16['
  end
  
  it "should convert values with ` postfix to 2/3 value" do
    cvt('a8 b8` c8').should == 
      'a8 b8*2/3 c8'
      
    cvt('g8 (g6` f g)').should ==
      'g8 g16*2/3( f g)'
  end
  
  it "should convert appoggiatura shorthand" do
    cvt('^e8 d4').should ==
      '\appoggiatura e8 d4'
    
    cvt('[c8 ^e6 d8]').should ==
      'c8[ \\appoggiatura e16 d8]'
  end
  
  it "case 01" do
    cvt('b8 (e6 d)').should ==
      'b8 e16( d)'
  end
end

describe "Use case" do
  it "01" do
    cvt("(a b2)\n   cs2\fermata cs4").should ==
      "a( b2)\n   cis2\fermata cis4"
  end
  
  it "02" do
    cvt("d8 [(cs6 b cs8)] a [b6 a gs fs]").should ==
      "d8 cis16[( b cis8)] a b16[ a gis fis]"
  end
  
  it "03" do
    cvt("([fs\\trill e]) gs-. a-. ([d,\\trill cs]) gs'-. a-.").should ==
      "fis([\\trill e]) gis-. a-. d,([\\trill cis]) gis'-. a-."
  end

  it "03.1" do
    cvt("([fs\\trill e])").should ==
      "fis([\\trill e])"
  end
  
  it "04" do
    cvt('(c,8.^"oboe II tacet" d6)').should ==
      'c,8.(^"oboe II tacet" d16)'
  end

  it "04.1" do
    cvt('(c,8.\p^"oboe II tacet" d6)').should ==
      'c,8.(\p^"oboe II tacet" d16)'
  end
  
  it "05" do
    cvt("\\times 2/3 { [(bb6 c bb)] } \\times 2/3 { [(a!6 bb a)] } ").should ==
      "\\times 2/3 { bes16[( c bes)] } \\times 2/3 { a!16[( bes a)] } "
  end

  it "06" do
    cvt("\\times 2/3 { bb6([ c bb)] } \\times 2/3 { a!6([ bb a)] } ").should ==
      "\\times 2/3 { bes16([ c bes)] } \\times 2/3 { a!16([ bes a)] } "
  end
  
  it "07" do
    cvt("(c6*2/3 db c)").should ==
      "c16*2/3( des c)"
  end
  
  it "08" do
    cvt("(a!8 b)").should ==
      "a!8( b)"
  end
  
  it "09" do
    cvt("(g2.*3/2 a)").should ==
      "g2.*3/2( a)"
  end
end

describe "[[]] sections" do
  it "should be included only in part mode" do
    cvt("a [[b c]]").should == 
      "a "

    cvt("a [[b c]]", :part).should == 
      "a b c"

    cvt("a [[b c]] d [[e f]]").should == 
      "a  d "
    
    cvt("a [[b c]] d [[(e f)]]", :part).should == 
      "a b c d e( f)"
  end
  
  it "should support line breaks" do
    cvt("a [[\nb c\n]]").should == 
      "a "

    cvt("a [[\nb c\n]]", :part).should == 
      "a \nb c\n"
  end
end

describe "![[]] sections (cue)" do
  it "should be included only in part mode" do
    cvt("a ![[b c]]").should == 
      "a "

    cvt("a ![[b c]]", :part).should == 
      "a \\new CueVoice { b c }"

    cvt("a ![[b c]] d ![[e f]]").should == 
      "a  d "
    
    cvt("a ![[b c]] d ![[(e f)]]", :part).should == 
      "a \\new CueVoice { b c } d \\new CueVoice { e( f) }"
  end
  
  it "should support line breaks" do
    cvt("a ![[\nb c\n]]").should == 
      "a "

    cvt("a ![[\nb c\n]]", :part).should == 
      "a \\new CueVoice { \nb c\n }"
  end
end

describe "{{}} sections" do
  it "should be included only in score or midi mode" do
    cvt("a {{b c}}").should == 
      "a "

    cvt("a {{b c}}", :score).should == 
      "a b c"

      cvt("a {{b c}}", :midi).should == 
        "a b c"

    cvt("a {{b c}} d {{e f}}").should == 
      "a  d "

    cvt("a {{b c}} d {{e f}}", :score).should == 
      "a b c d e f"
  end
  
  it "should support line breaks" do
    cvt("a {{\nb c\n}}").should == 
      "a "

    cvt("a {{\nb c\n}}", :score).should == 
      "a \nb c\n"
  end
end

describe "m{{}} sections" do
  it "should be included only in midi mode" do
    cvt("a m{{b c}}").should == 
      "a "

    cvt("a m{{b c}}", :midi).should == 
      "a b c"

    cvt("a m{{b c}} d m{{e f}}").should == 
      "a  d "

    cvt("a m{{b c}} d m{{e f}}", :midi).should == 
      "a b c d e f"
  end
  
  it "should support line breaks" do
    cvt("a m{{\nb c\n}}").should == 
      "a "

    cvt("a m{{\nb c\n}}", :midi).should == 
      "a \nb c\n"
  end
end

describe "m{{}} use case" do
  it "01" do
    cvt('\bar "||" \time 3/4

     m{{\tempo 4=104}}

    d, c b a6 g fis8 d
    g fis g a b c').strip.should == '\bar "||" \time 3/4

     

    d, c b a16 g fis8 d
    g fis g a b c'
  end
end

describe "macro mode" do
  it "should be entered using $!...$ syntax" do
    cvt("$!(#8. #6)$ g g g g g g").should ==
      "g8.( g16) g8.( g16) g8.( g16) "
  end
  
  it "should be exited using $$ syntax" do
    cvt("$!(#8. #6)$ g g g g g g $$ g2").should ==
      "g8.( g16) g8.( g16) g8.( g16)  g2"
  end
  
  it "should allow named macros" do
    cvt("$!(#8. #6)$:8.6 g g g g g g $$ g2 $8.6 g g $$ g4").should ==
      "g8.( g16) g8.( g16) g8.( g16)  g2 g8.( g16)  g4"
  end
  
  it "should support macros defined in config" do
    cvt("$8.6 g g $$ g4", nil, {"macros" => {"8.6" => "(#8. #6)"}}).should ==
      "g8.( g16)  g4"
  end
  
  it "should support note repetition" do
    cvt("$!(#8. @6 #8 #)$ g b d").should ==
      "g8.( g16 b8 d) "
  end
end

describe "divisi shorthand" do
  it "should be entered using /1 ... /2 ... /u syntax" do
    cvt("/1 a4 /2 b4 /u c2").should == 
      "<< { \\voiceOne a4 } \\new Voice { \\voiceTwo b4 } >> \\oneVoice c2"
  end
  
  it "use case 1 (BWV 52/1)" do
    cvt("/1 g6^\"Violoncelli\" d g a g f e d cs8 /2 g'8 r r4 r8 /u a, b cs").should == 
      "<< { \\voiceOne g6^\"Violoncelli\" d g a g f e d cs8 } \\new Voice { \\voiceTwo g'8 r r4 r8 } >> \\oneVoice a, b cs"
  end
end

describe "macro use case" do
  it "01" do
    src = "$8.6 g g
g g g g g g 
g g g g g g 
g g g g g g $$
g4 r g'
fs e d 
cs d cs
b g a
$8.6 d, d d d d  d 
d d d d d d 
d d d d d d 
d d d d d d $$
d2."
    
    cvt(src, nil, {"macros" => {"8.6" => "(#8. #6)"}}).should == 
      "g8.( g16) g8.( g16) g8.( g16) g8.( g16) g8.( g16) g8.( g16) g8.( g16) g8.( g16) g8.( g16) g8.( g16) 
g4 r g'
fis e d 
cis d cis
b g a
d,8.( d16) d8.( d16) d8.( d16) d8.( d16) d8.( d16) d8.( d16) d8.( d16) d8.( d16) d8.( d16) d8.( d16) d8.( d16) d8.( d16) 
d2."
  end
  
  it "02" do
    src = "$8.6 g g g\\p g g g $$"
    cvt(src, nil, {"macros" => {"8.6" => "(#8. #6)"}}).should == 
      "g8.( g16) g8.(\\p g16) g8.( g16) "
  end
  
  it "03" do
    src = "$t2 bb c bb a! bb a $$"
    cvt(src, nil, {"macros" => {"t2" => "\\times 2/3 { #6[( # #)] }"}}).should ==
      "\\times 2/3 { bes16[( c bes)] } \\times 2/3 { a!16[( bes a)] } "
  end
end

describe "variable references" do
  it "should be converted to their values" do
    config = {"blah" => {"bluh" => "tenor"}}
    config.deep = true
    cvt("\\clef %blah/bluh% c4", nil, config).should ==
      "\\clef tenor c4"
  end
end

describe "crossbar dot .|" do
  it "should be expanded into lilypond construct" do
    cvt("c2 d2.| e4 f g").should ==
      "c2 \\once \\override Tie #'transparent = ##t d2 ~ \\once \\override NoteHead #'transparent = ##t \\once \\override Dots #'extra-offset = #'(-1.3 . 0) \\once \\override Stem #'transparent = ##t d2.*0 s4 e4 f g"
  end

  it "should handle octave disposition" do
    cvt("c d'4.|\\p e8 f g").should ==
      "c \\once \\override Tie #'transparent = ##t d'4\\p ~ \\once \\override NoteHead #'transparent = ##t \\once \\override Dots #'extra-offset = #'(-1.3 . 0) \\once \\override Stem #'transparent = ##t d4.*0 s8 e8 f g"
  end

  it "should handle attached objects" do
    cvt("c d4.|\\p e8 f g").should ==
      "c \\once \\override Tie #'transparent = ##t d4\\p ~ \\once \\override NoteHead #'transparent = ##t \\once \\override Dots #'extra-offset = #'(-1.3 . 0) \\once \\override Stem #'transparent = ##t d4.*0 s8 e8 f g"
  end
  
  it "should handle prefixed (" do
    cvt("c (d4.|\\p e8 f g").should ==
      "c \\once \\override Tie #'transparent = ##t d4(\\p ~ \\once \\override NoteHead #'transparent = ##t \\once \\override Dots #'extra-offset = #'(-1.3 . 0) \\once \\override Stem #'transparent = ##t d4.*0 s8 e8 f g"
  end
end


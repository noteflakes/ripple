require File.expand_path(File.join(File.dirname(__FILE__), '../lib/ripple'))

include Ripple::Syntax

context "Syntax converter" do
  specify "should correctly convert accidentals" do
    convert_syntax('c cs d ds e es f fs g gs a as b bs').should ==
      'c cis d dis e eis f fis g gis a ais b bis'
      
    convert_syntax('c cb d db e eb f fb g gb a ab b bb').should ==
      'c ces d des e ees f fes g ges a aes b bes'
      
    convert_syntax('css d ebb').should ==
      'cisis d eeses'
      
    convert_syntax('cs1 bb- es! ab(').should ==
      'cis1 bes- eis! aes('
  end
  
  specify "should move prefixed [ to after note" do
    convert_syntax('[a b c]').should ==
      'a[ b c]'

    convert_syntax('[ a,4 b c]').should ==
      'a,4[ b c]'

    convert_syntax("a b c [\nd").should ==
      'a b c d['
  end
  
  specify "should convert [ before line-break" do
    convert_syntax("[\nd8 c b").should ==
      'd8[ c b'

    convert_syntax("d8[\nd8 c b").should ==
      "d8[\nd8 c b"
  end

  specify "should move prefixed ( to after note" do
    convert_syntax('[a b c]').should ==
      'a[ b c]'

    convert_syntax('[ a,4 b c]').should ==
      'a,4[ b c]'

    convert_syntax("a b c [\nd").should ==
      'a b c d['
  end
  
  specify "should not convert postfixed [" do
    convert_syntax('a[ b]').should ==
      'a[ b]'
  end
  
  specify "should not convert postfixed (" do
    convert_syntax('a( b)').should ==
      'a( b)'
  end
  
  specify "should convert 3,6 values to 32, 16 values" do
    convert_syntax('a3 b6 b,,3 e6(').should ==
      'a32 b16 b,,32 e16('
      
    convert_syntax('r6 b3 [a6').should ==
      'r16 b32 a16['
  end
  
  specify "should convert appoggiatura shorthand" do
    convert_syntax('^e8 d4').should ==
      '\appoggiatura e8 d4'
    
    convert_syntax('[c8 ^e6 d8]').should ==
      'c8[ \\appoggiatura e16 d8]'
  end
  
  specify "case 01" do
    convert_syntax('b8 (e6 d)').should ==
      'b8 e16( d)'
  end
end

context "Use case" do
  specify "01" do
    convert_syntax("(a b2)\n   cs2\fermata cs4").should ==
      "a( b2)\n   cis2\fermata cis4"
  end
  
  specify "02" do
    convert_syntax("d8 [(cs6 b cs8)] a [b6 a gs fs]").should ==
      "d8 cis16[( b cis8)] a b16[ a gis fis]"
  end
  
  specify "03" do
    convert_syntax("([fs\\trill e]) gs-. a-. ([d,\\trill cs]) gs'-. a-.").should ==
      "fis[(\\trill e]) gis-. a-. d,[(\\trill cis]) gis'-. a-."
  end

  specify "03.1" do
    convert_syntax("([fs\\trill e])").should ==
      "fis[(\\trill e])"
  end
  
  specify "04" do
    convert_syntax('(c,8.^"oboe II tacet" d6)').should ==
      'c,8.(^"oboe II tacet" d16)'
  end

  specify "04.1" do
    convert_syntax('(c,8.\p^"oboe II tacet" d6)').should ==
      'c,8.(\p^"oboe II tacet" d16)'
  end
end

context "\\partOnly sections" do
  specify "should be included only in part mode" do
    convert_syntax("a \\partOnly {{b c}}").should == 
      "a "

    convert_syntax("a \\partOnly {{b c}}", true, :part).should == 
      "a b c"

    convert_syntax("a \\partOnly {{b c}} d \\partOnly {{e f}}").should == 
      "a  d "

    convert_syntax("a \\partOnly {{b c}} d \\partOnly {{e f}}", true, :part).should == 
      "a b c d e f"
  end
  
  specify "should support line breaks" do
    convert_syntax("a \\partOnly {{\nb c\n}}").should == 
      "a "

    convert_syntax("a \\partOnly {{\nb c\n}}", true, :part).should == 
      "a \nb c\n"
  end
end

context "\\scoreOnly sections" do
  specify "should be included only in score mode" do
    convert_syntax("a \\scoreOnly {{b c}}").should == 
      "a "

    convert_syntax("a \\scoreOnly {{b c}}", true, :score).should == 
      "a b c"

    convert_syntax("a \\scoreOnly {{b c}} d \\scoreOnly {{e f}}").should == 
      "a  d "

    convert_syntax("a \\scoreOnly {{b c}} d \\scoreOnly {{e f}}", true, :score).should == 
      "a b c d e f"
  end
  
  specify "should support line breaks" do
    convert_syntax("a \\scoreOnly {{\nb c\n}}").should == 
      "a "

    convert_syntax("a \\scoreOnly {{\nb c\n}}", true, :score).should == 
      "a \nb c\n"
  end
end

context "\\midiOnly sections" do
  specify "should be included only in midi mode" do
    convert_syntax("a \\midiOnly {{b c}}").should == 
      "a "

    convert_syntax("a \\midiOnly {{b c}}", true, :midi).should == 
      "a b c"

    convert_syntax("a \\midiOnly {{b c}} d \\midiOnly {{e f}}").should == 
      "a  d "

    convert_syntax("a \\midiOnly {{b c}} d \\midiOnly {{e f}}", true, :midi).should == 
      "a b c d e f"
  end
  
  specify "should support line breaks" do
    convert_syntax("a \\midiOnly {{\nb c\n}}").should == 
      "a "

    convert_syntax("a \\midiOnly {{\nb c\n}}", true, :midi).should == 
      "a \nb c\n"
  end
end
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/ripple'))

include Ripple::Syntax

context "Syntax converter" do
  specify "should correctly convert accidentals" do
    convert_rpl('c cs d ds e es f fs g gs a as b bs').should ==
      'c cis d dis e eis f fis g gis a ais b bis'
      
    convert_rpl('c cb d db e eb f fb g gb a ab b bb').should ==
      'c ces d des e ees f fes g ges a aes b bes'
      
    convert_rpl('css d ebb').should ==
      'cisis d eeses'
      
    convert_rpl('cs1 bb- es! ab(').should ==
      'cis1 bes- eis! aes('
  end
  
  specify "should move prefixed [ to after note" do
    convert_rpl('[a b c]').should ==
      'a[ b c]'

    convert_rpl('[ a,4 b c]').should ==
      'a,4[ b c]'

    convert_rpl("a b c [\nd").should ==
      'a b c d['
  end
  
  specify "should convert [ before line-break" do
    convert_rpl("[\nd8 c b").should ==
      'd8[ c b'

    convert_rpl("d8[\nd8 c b").should ==
      "d8[\nd8 c b"
  end

  specify "should move prefixed ( to after note" do
    convert_rpl('[a b c]').should ==
      'a[ b c]'

    convert_rpl('[ a,4 b c]').should ==
      'a,4[ b c]'

    convert_rpl("a b c [\nd").should ==
      'a b c d['
  end
  
  specify "should not convert postfixed [" do
    convert_rpl('a[ b]').should ==
      'a[ b]'
  end
  
  specify "should not convert postfixed (" do
    convert_rpl('a( b)').should ==
      'a( b)'
  end
  
  specify "should convert 3,6 values to 32, 16 values" do
    convert_rpl('a3 b6 b,,3 e6(').should ==
      'a32 b16 b,,32 e16('
      
    convert_rpl('r6 b3 [a6').should ==
      'r16 b32 a16['
  end
  
  specify "should convert appoggiatura shorthand" do
    convert_rpl('^e8 d4').should ==
      '\appoggiatura e8 d4'
    
    convert_rpl('[c8 ^e6 d8]').should ==
      'c8[ \\appoggiatura e16 d8]'
  end
  
  specify "case 01" do
    convert_rpl('b8 (e6 d)').should ==
      'b8 e16( d)'
  end
end

context "Use case" do
  specify "01" do
    convert_rpl("(a b2)\n   cs2\fermata cs4").should ==
      "a( b2)\n   cis2\fermata cis4"
  end
  
  specify "02" do
    convert_rpl("d8 [(cs6 b cs8)] a [b6 a gs fs]").should ==
      "d8 cis16[( b cis8)] a b16[ a gis fis]"
  end
  
  specify "03" do
    convert_rpl("([fs\\trill e]) gs-. a-. ([d,\\trill cs]) gs'-. a-.").should ==
      "fis\\trill[( e]) gis-. a-. d,\\trill[( cis]) gis'-. a-."
  end

  specify "03.1" do
    convert_rpl("([fs\\trill e])").should ==
      "fis\\trill[( e])"
  end
end

context "\\partOnly sections" do
  specify "should be included only in part mode" do
    convert_rpl("a \\partOnly {{b c}}").should == 
      "a "

    convert_rpl("a \\partOnly {{b c}}", :part).should == 
      "a b c"

    convert_rpl("a \\partOnly {{b c}} d \\partOnly {{e f}}").should == 
      "a  d "

    convert_rpl("a \\partOnly {{b c}} d \\partOnly {{e f}}", :part).should == 
      "a b c d e f"
  end
  
  specify "should support line breaks" do
    convert_rpl("a \\partOnly {{\nb c\n}}").should == 
      "a "

    convert_rpl("a \\partOnly {{\nb c\n}}", :part).should == 
      "a \nb c\n"
  end
end

context "\\scoreOnly sections" do
  specify "should be included only in score mode" do
    convert_rpl("a \\scoreOnly {{b c}}").should == 
      "a "

    convert_rpl("a \\scoreOnly {{b c}}", :score).should == 
      "a b c"

    convert_rpl("a \\scoreOnly {{b c}} d \\scoreOnly {{e f}}").should == 
      "a  d "

    convert_rpl("a \\scoreOnly {{b c}} d \\scoreOnly {{e f}}", :score).should == 
      "a b c d e f"
  end
  
  specify "should support line breaks" do
    convert_rpl("a \\scoreOnly {{\nb c\n}}").should == 
      "a "

    convert_rpl("a \\scoreOnly {{\nb c\n}}", :score).should == 
      "a \nb c\n"
  end
end

context "\\midiOnly sections" do
  specify "should be included only in midi mode" do
    convert_rpl("a \\midiOnly {{b c}}").should == 
      "a "

    convert_rpl("a \\midiOnly {{b c}}", :midi).should == 
      "a b c"

    convert_rpl("a \\midiOnly {{b c}} d \\midiOnly {{e f}}").should == 
      "a  d "

    convert_rpl("a \\midiOnly {{b c}} d \\midiOnly {{e f}}", :midi).should == 
      "a b c d e f"
  end
  
  specify "should support line breaks" do
    convert_rpl("a \\midiOnly {{\nb c\n}}").should == 
      "a "

    convert_rpl("a \\midiOnly {{\nb c\n}}", :midi).should == 
      "a \nb c\n"
  end
end
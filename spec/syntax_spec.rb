require File.expand_path(File.join(File.dirname(__FILE__), '../lib/ripple'))

include Ripple::Syntax

context "Syntax converter" do
  specify "should correctly convert accidentals" do
    convert('c cs d ds e es f fs g gs a as b bs').should ==
      'c cis d dis e eis f fis g gis a ais b bis'
      
    convert('c cb d db e eb f fb g gb a ab b bb').should ==
      'c ces d des e ees f fes g ges a aes b bes'
      
    convert('css d ebb').should ==
      'cisis d eeses'
      
    convert('cs1 bb- es! ab(').should ==
      'cis1 bes- eis! aes('
  end
  
  specify "should move prefixed [ to after note" do
    convert('[a b c]').should ==
      'a[ b c]'

    convert('[ a,4 b c]').should ==
      'a,4[ b c]'

    convert("a b c [\nd").should ==
      'a b c d['
  end

  specify "should move prefixed ( to after note" do
    convert('[a b c]').should ==
      'a[ b c]'

    convert('[ a,4 b c]').should ==
      'a,4[ b c]'

    convert("a b c [\nd").should ==
      'a b c d['
  end
  
  specify "should convert 3,6 values to 32, 16 values" do
    convert('a3 b6 b,,3 e6(').should ==
      'a32 b16 b,,32 e16('
      
    convert('r6 b3 [a6').should ==
      'r16 b32 a16['
  end
  
  specify "should convert appoggiatura shorthand" do
    convert('^e8 d4').should ==
      '\appoggiatura e8 d4'
    
    convert('[c8 ^e6 d8]').should ==
      'c8[ \\appoggiatura e16 d8]'
  end
end
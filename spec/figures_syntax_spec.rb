require File.expand_path(File.join(File.dirname(__FILE__), './spec_helper'))

def cvt_figures(input, mode = nil, config = {})
  Ripple::FigureSyntax.cvt(input, mode, config)
end

describe "Figure syntax converter" do
  it "use case 1 (BWV135/1)" do
    cvt_figures("% excerpt from BWV 135/1
    #/2.
    ,/2 642/4
    65 642 5/8 6`
    54/4 _3 6/8 5
    7#/4 642' 75#
    65# _4 5#
    64 7`42'/2
    85#/2.
    ,/2.*4
    6`/2.
    6
    7/4 6/2
    7#/4 64 5# % blah blah
    65#/8 _4 5#/4 64
    642 7`42/2
    853/2.
    ,").should == "<_+>2. s2 <6 4 2>4 <6 5> <6 4 2> <5>8 <6\\\\> <5 4>4 \\bassFigureExtendersOn <5 3> \\bassFigureExtendersOff <6>8 <5> <7 _+>4 <6 4 2/> <7 5 _+> <6 5 _+> \\bassFigureExtendersOn <6 4> \\bassFigureExtendersOff <5 _+> <6 4> <7\\\\ 4 2/>2 <8 5 _+>2. s2.*4 <6\\\\>2. <6> <7>4 <6>2 <7 _+>4 <6 4> <5 _+> <6 5 _+>8 \\bassFigureExtendersOn <6 4> \\bassFigureExtendersOff <5 _+>4 <6 4> <6 4 2> <7\\\\ 4 2>2 <8 5 3>2. s"
  end
  
  it "use case 2" do
    cvt_figures("6-4!2/4").should == "<6- 4! 2>4"
  end
  
  it "should convert figures preceded by ? to transparent figures" do
    cvt_figures("?6/4").should == "\\once \\override BassFigure #'implicit = ##t <6>4"
  end
end

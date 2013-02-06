require File.expand_path(File.join(File.dirname(__FILE__), './spec_helper'))

def cvt_lyrics(input, mode = nil, config = {})
  Ripple::LyricsSyntax.cvt(input, mode, config)
end

describe "Lyrics syntax converter" do
  it "use case 1 (BuxWV 60)" do
    cvt_lyrics("Je-su mei-ne Freu--de, mei-nes Her-zens Wei--de, Je-su mei-ne Zier").
      should == "Je -- su mei -- ne Freu -- _ de, mei -- nes Her -- zens Wei -- _ de, Je -- su mei -- ne Zier"
  end
  
  it "use case 2" do
    cvt_lyrics("O heil'-ges geist\\- und Was----ser-bad__").
      should == "O heil' -- ges geist- und Was -- _ _ _ ser -- bad __ _ "
  
    cvt_lyrics("O heil'-ges geist\\-_ und Was----ser-bad__").
      should == "O heil' -- ges geist- __  und Was -- _ _ _ ser -- bad __ _ "
  end
end

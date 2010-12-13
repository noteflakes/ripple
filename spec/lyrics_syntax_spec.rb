require File.expand_path(File.join(File.dirname(__FILE__), '../lib/ripple'))

def cvt(input, mode = nil, config = {})
  Ripple::LyricsSyntax.cvt(input, mode, config)
end

context "Lyrics syntax converter" do
  specify "use case 1 (BuxWV 60)" do
    cvt("Je-su mei-ne Freu--de, mei-nes Her-zens Wei--de, Je-su mei-ne Zier").
      should == "Je -- su mei -- ne Freu -- _ de, mei -- nes Her -- zens Wei -- _ de, Je -- su mei -- ne Zier"
  end
  
  specify "use case 2" do
    cvt("O heil'-ges geist\\- und Was----ser-bad__").
      should == "O heil' -- ges geist- und Was -- _ _ _ ser -- bad __ _ "
  
    cvt("O heil'-ges geist\\-_ und Was----ser-bad__").
      should == "O heil' -- ges geist- __  und Was -- _ _ _ ser -- bad __ _ "
  end
end

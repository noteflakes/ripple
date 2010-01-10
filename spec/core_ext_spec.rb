require File.expand_path(File.join(File.dirname(__FILE__), '../lib/ripple'))

context "Hash#lookup" do
  before(:each) do
    @h = {
      "a" => 1, 
      "b" => {
        "c" => 2, 
        "d" => 3
      }, 
      "e" => {
        "f" => {
          "g" => 4, 
          "h" => {
            "i" => 5
          }
        }
      }
    }
  end
  
  specify "should act like Hash#[] for flat paths" do
    @h.lookup("a").should == 1
    @h.lookup("b").should == {"c" => 2, "d" => 3}
    @h.lookup("c").should be_nil
    @h.lookup("e").should == {"f" => {"g" => 4, "h" => {"i" => 5}}}
  end
  
  specify "should provide deep access" do
    @h.lookup("b/c").should == 2
    @h.lookup("b/d").should == 3
    @h.lookup("e/f").should == {"g" => 4, "h" => {"i" => 5}}
    @h.lookup("e/f/g").should == 4
    @h.lookup("e/f/h").should == {"i" => 5}
    @h.lookup("e/f/h/i").should == 5
  end
end

context "Hash#set" do
  before(:each) do
    @h = {
      "a" => 1, 
      "b" => {
        "c" => 2, 
        "d" => 3
      }, 
      "e" => {
        "f" => {
          "g" => 4, 
          "h" => {
            "i" => 5
          }
        }
      }
    }
  end
  
  specify "should act like Hash#[]= for flat paths" do
    @h.set("a", 7)
    @h.should == {"a" => 7, "b" => {"c" => 2, "d" => 3}, 
      "e" => {"f" => {"g" => 4, "h" => {"i" => 5}}}}
  end
  
  specify "should support deep access" do
    @h.set("a/z/x", 8)
    @h.should == {"a" => {"z" => {"x" => 8}}, "b" => {"c" => 2, "d" => 3}, 
      "e" => {"f" => {"g" => 4, "h" => {"i" => 5}}}}
      
    @h.set("b/c", 9)
    @h.should == {"a" => {"z" => {"x" => 8}}, "b" => {"c" => 9, "d" => 3}, 
      "e" => {"f" => {"g" => 4, "h" => {"i" => 5}}}}
  end
end

context "Array#array_index" do
  before(:each) do
    @a = [1,2,3,4,5]
  end
  
  specify "should return the index of the passed argument in the array" do
    @a.array_index([1,2,3]).should == 0
    @a.array_index([1,2,3,4]).should == 0
    @a.array_index([1,2,3,4,5]).should == 0
    @a.array_index([5]).should == 4
    @a.array_index([5,6]).should == nil

    @a.array_index([3,4]).should == 2
    @a.array_index([3,5]).should == nil
  end
end

context "String#ly_inspect" do
  specify "should properly escape quotes" do
    s = "r \"i\" p"
    s.ly_inspect.should == "\"r \\\"i\\\" p\""
  end
  
  specify "should not escape unicode characters" do
    s = "\"Allein Gott in der Höh' sei Ehr'\""
    s.ly_inspect.should == "\"\\\"Allein Gott in der H\303\266h' sei Ehr'\\\"\""
  end
end

context "String#to_instrument_title" do
  specify "should recognize indexed instruments" do
    "violino1".to_instrument_title.should == 'Violino I'
    "violino3".to_instrument_title.should == 'Violino III'
  end
  
  specify "should handle multiple words in title" do
    "viola-da-gamba1".to_instrument_title.should == 'Viola da gamba I'
  end
end

context "String#to_movement_title" do
  specify "should work with numbered titles" do
    "01-blah-blah".to_movement_title.should == '1. Blah Blah'
  end

  specify "should work with numbers only" do
    "01".to_movement_title.should == 'I'
    "09".to_movement_title.should == 'IX'
  end
  
  specify "should omit number when prefixed with a dash" do
    "-01-Blah".to_movement_title.should == 'Blah'
    "-09-Versus-VIII".to_movement_title.should == 'Versus VIII'
  end
end
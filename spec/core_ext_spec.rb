require File.expand_path(File.join(File.dirname(__FILE__), '../lib/ripple'))

context "Hash#lookup" do
  setup do
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
    @h["a"].should == 1
    @h["b"].should == {"c" => 2, "d" => 3}
    @h["c"].should be_nil
    @h["e"].should == {"f" => {"g" => 4, "h" => {"i" => 5}}}
  end
  
  specify "should provide deep access" do
    @h["b/c"].should == 2
    @h["b/d"].should == 3
    @h["e/f"].should == {"g" => 4, "h" => {"i" => 5}}
    @h["e/f/g"].should == 4
    @h["e/f/h"].should == {"i" => 5}
    @h["e/f/h/i"].should == 5
  end
end

context "Hash#set" do
  setup do
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

context "Hash#[]" do
  setup do
    @h = {"a" => 1, "b" => 2, 3 => 4, "c" => {"d" => 5, "e" => {"f" => 6}}}
  end
  
  specify "should work like the stock method for non-strings and flat paths" do
    @h["a"].should == 1
    @h["b"].should == 2
    @h[3].should == 4
    @h[5].should be_nil
  end
  
  specify "should work like Hash#lookup for deep paths" do
    @h["c/d"].should == 5
    @h["c/e"].should == {"f" => 6}
    @h["c/e/f"].should == 6
    @h["c/e/g"].should be_nil
  end
end

context "Hash#[]=" do
  setup do
    @h = {"a" => 1, "b" => 2, 3 => 4, "c" => {"d" => 5, "e" => {"f" => 6}}}
  end
  
  specify "should work like the stock method for non-strings and flat paths" do
    @h["a"] = 7
    @h.should == {"a" => 7, "b" => 2, 3 => 4, "c" => {"d" => 5, "e" => {"f" => 6}}}
    
    @h[8] = 9
    @h.should == {"a" => 7, "b" => 2, 3 => 4, "c" => {"d" => 5, "e" => {"f" => 6}}, 8 => 9}
  end
  
  specify "should work like Hash#set for deep paths" do
    @h["c/d"] = 7
    @h.should == {"a" => 1, "b" => 2, 3 => 4, "c" => {"d" => 7, "e" => {"f" => 6}}}
    
    
    @h["c/e"] = 8
    @h.should == {"a" => 1, "b" => 2, 3 => 4, "c" => {"d" => 7, "e" => 8}}

    @h["c/e/f"] = 9
    @h.should == {"a" => 1, "b" => 2, 3 => 4, "c" => {"d" => 7, "e" => {"f" => 9}}}
  end
end

context "Array#array_index" do
  setup do
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
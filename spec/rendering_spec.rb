require File.expand_path(File.join(File.dirname(__FILE__), '../lib/ripple'))

context "Staff group hierarchy algorithm" do
  setup do
    yaml = <<EOF
score:
  order:
    - oboe1
    - oboe2
    - violino1
    - violino2
    - viola
    - soprano
    - alto
    - tenore
    - basso
    - continuo
  groups:
    - brace: [oboe1, oboe2]
    - brace: [violino1, violino2]
    - bracket: [soprano, alto, tenore, basso]
EOF
    @config = YAML.load(yaml)
  end
  
  specify "should create the correct hierarchy when all staves are present" do
    parts = @config['score/order']
    parts.should == %w[oboe1 oboe2 violino1 violino2 viola soprano alto tenore basso continuo]
    
    Ripple::Templates.staff_groups(parts, @config).should == [
      {"brace" => %w[oboe1 oboe2]},
      {"brace" => %w[violino1 violino2]},
      "viola",
      {"bracket" => %w[soprano alto tenore basso]},
      "continuo"
    ]
  end

  specify "should create the correct hierarchy when only some of the staves are present" do
    parts = %w[violino1 violino2 soprano continuo]
    
    Ripple::Templates.staff_groups(parts, @config).should == [
      {"brace" => %w[violino1 violino2]},
      "soprano",
      "continuo"
    ]

    parts = %w[violino soprano alto continuo]
    
    Ripple::Templates.staff_groups(parts, @config).should == [
      "violino",
      {"bracket" => %w[soprano alto]},
      "continuo"
    ]
  end
  
  specify "should render the correct systemStartDelimiterHierarchy expression for full score" do
    parts = @config['score/order']
    parts.should == %w[oboe1 oboe2 violino1 violino2 viola soprano alto tenore basso continuo]
    
    Ripple::Templates.staff_hierarchy(parts, @config).should == "#'(SystemStartBracket (SystemStartBrace oboe1 oboe2) (SystemStartBrace violino1 violino2) viola (SystemStartBracket soprano alto tenore basso) continuo)"
  end

  specify "should render the correct systemStartDelimiterHierarchy expression for partial score" do
    parts = %w[violino1 violino2 soprano continuo]
    Ripple::Templates.staff_hierarchy(parts, @config).should == "#'(SystemStartBracket (SystemStartBrace violino1 violino2) soprano continuo)"

    parts = %w[violino soprano alto continuo]
    Ripple::Templates.staff_hierarchy(parts, @config).should == "#'(SystemStartBracket violino (SystemStartBracket soprano alto) continuo)"
  end
end
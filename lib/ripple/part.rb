require 'erb'

module Ripple
  class Part
    def initialize(path, config)
      @content = IO.read(path)
      @config = config

      if @content =~ /^(---\s*\n.*?)\n---\s*\n/m
        @content = @content[($1.size + 5)..-1]
        @config.merge(YAML.load($1))
      end
    end
    
    def process(opts = {})
      
    end
  end
end

__END__

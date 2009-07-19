require 'find'

module Ripple
  class Work
    attr_reader :path, :config
    
    def initialize(path, config = {})
      @path = File.expand_path(path)
      @config = config.merge(work_config)
    end
    
    def relative_path
      root = File.expand_path(config["source"])
      path =~ /^#{root}\/(.+)$/ && $1
    end
    
    def work_config
      YAML.load(IO.read(File.join(@path, "_work.yml"))) rescue {}
    end
    
    def movements
      @movements ||= Dir[File.join(@path, "**")].
        reject {|fn| !File.directory?(fn)}.map do |fn|
          fn =~ /^#{@path}\/(.+)$/ && $1
        end.sort
    end
    
    def parts
      @parts ||= Dir[File.join(@path, "**/*.rly")].
        reject {|fn| !File.file?(fn)}.map do |fn|
          File.basename(fn, ".rly")
        end.uniq.sort
    end
    
    def process(opts = {})
      parts.each {|p| Part.new(p, self).process}
      # if parts.size > 1
      #   Score.new(self).process
      # end
    end
  end
end
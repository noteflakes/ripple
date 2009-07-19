require 'find'

module Ripple
  class Work
    def initialize(path, config)
      @path = File.expand_path(path)
      @config = config.merge(work_attributes)
    end
    
    def work_attributes
      YAML.load(IO.read(File.join(@path, "_work.yml"))) rescue {}
    end
    
    def part_files
      Dir[File.join(@path, "**/*.rly")].
        map {|fn| fn =~ /^#{@path}\/(.+)$/ && $1 }
    end
    
    def process(opts = {})
      files = part_files
      files.each {|fn| Part.new(fn, @config).process}
      if files.size > 1
        Score.new(files).process
    end
  end
end
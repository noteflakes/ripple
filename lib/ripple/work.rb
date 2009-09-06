require 'find'

module Ripple
  class Work
    attr_reader :path, :config
    
    def initialize(path, config = {})
      @path = File.expand_path(path)
      @config = config.deep_merge(work_config)
    end
    
    def relative_path
      root = File.expand_path(config["source"])
      path =~ /^#{root}\/(.+)$/ ? $1 : "."
    end
    
    def work_config
      YAML.load(IO.read(File.join(@path, "_work.yml"))) rescue {}
    end
    
    def movements
      return @movements if @movements
      @movements = Dir[File.join(@path, "**")].
        reject {|fn| File.basename(fn) =~ /^_/ || !File.directory?(fn)}.map do |fn|
          fn =~ /^#{@path}\/(.+)$/ && $1
        end
      @movements << "" if @movements.empty?
      @movements.sort!
    end
    
    def all_parts
      return @parts if @parts
      @parts = Dir[File.join(@path, "**/*.rpl"), File.join(@path, "**/*.ly")].
        reject {|fn| !File.file?(fn) || File.basename(fn) =~ /^_/}.
        map  {|fn| File.basename(fn, ".*")}

      # (@config["parts"] || {}).each do |p, opts|
      #   @parts << p if opts["source"] && !opts["ignore"]
      # end

      @parts.uniq!
      @parts.sort!
    end
    
    def process
      if selected_parts = @config["selected_parts"]
        parts = selected_parts.split(',')
      else
        parts = all_parts
      end
      parts.each {|p| Part.new(p, self).process} unless @config["score_only"]

      if (parts.size > 1) && !config["no_score"]
        Score.new(self).process unless @config["parts_only"]
      end
    end
  end
end
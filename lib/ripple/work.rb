require 'find'

module Ripple
  class Work
    attr_reader :name, :path, :config
    
    def initialize(path, config = {})
      @path = File.expand_path(path)
      @name = (@path =~ /([^\/]+)$/) && $1
      @config = config.deep_merge(work_config)
    end
    
    def relative_path
      source_dir = File.expand_path(config["source"])
      config_dir = @config['config_file_dir']
      path =~ /^(?:#{source_dir}|#{config_dir})\/(.+)$/ ? $1 : "."
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
      
      do_parts = !@config["no_parts"]
      do_score = !@config["no_score"]
      do_vocal = @config["vocal"]
      
      # inhibit part rendering if score_only specified and no parts specified.
      if selected_parts && !@config["score_only"]
        do_score = false
        do_vocal = false
      # inhibit score rendering if parts specified and not score_only.
      elsif !selected_parts && @config["score_only"]
        do_parts = false
      elsif @config["vocal_only"]
        do_parts = false
        do_score = false
        do_vocal = true # force even if no vocal config is found
      end
      
      parts.each {|p| Part.new(p, self).process} if do_parts
      Score.new(self).process if do_score
      VocalScore.new(self).process if do_vocal
    end
  end
end
module Ripple
  class Compilation
    attr_reader :config, :path
    
    def initialize(config = {})
      @path = File.expand_path(config["compile"])
      @path += ".yml" if @path !~ /\.yml/
      @config = config.deep_merge(compilation_config)
      compute_movement_titles
    end
    
    def name
      n = (@path =~ /([^\/]+)$/) && $1
      n = (n =~ /^(.+)\.yml$/) && $1
    end
    
    def compilation_config
      YAML.load(IO.read(@path)) rescue {}
    end
    
    def clean_config
      @config.reject {|k, v| k == "movements" || k == "compile"}
    end
    
    def compute_movement_titles
      @config["movements"].each_with_index do |m, i|
        w = Work.new(m["work"], clean_config)
        mvt = (m["movement"] =~ /^(\d+)\-(.+)/) ? 
          "#{$1.to_i} - #{$2.titlize(true)}" : m["movement"]
        m["title"] ||= "%d. %s/%s" % [i + 1, w.name, mvt]
      end
    end
    
    def relative_path
      root = File.expand_path(config["source"])
      p = (path =~ /^(.+)\.yml$/) && $1
      p =~ /^#{root}\/(.+)$/ ? $1 : "."
    end
    
    def all_parts
      # for now return an empty array. later we'll go over all
      # movements and compute a union
      []
    end
    
    def process
      if selected_parts = @config["selected_parts"]
        parts = selected_parts.split(',')
      else
        parts = all_parts
      end
      
      do_parts = !@config["no_parts"]
      do_score = !@config["no_score"]
      
      # inhibit part rendering if score_only specified and no parts specified.
      if selected_parts && !@config["score_only"]
        do_score = false
      # inhibit score rendering if parts specified and not score_only.
      elsif !selected_parts && @config["score_only"]
        do_parts = false
      elsif @config["vocal_only"]
        do_parts = false
        do_score = false
      end
      
      parts.each {|p| Part.new(p, self).process} if do_parts
      CompilationScore.new(self).process if do_score
    end
  end
  
  class CompilationScore < Score
    def initialize(compilation)
      @compilation = compilation
      @compilation_config = compilation.config
      @work = compilation
      @config = compilation.config
    end
    
    def movements
      @compilation.config["movements"]
    end
    
    
    
    def ly_filename(mvt = nil)
      File.join(@compilation_config["ly_dir"], @compilation.relative_path, 
        (mvt ? "#{mvt}.ly" : "score.ly"))
    end
    
    def pdf_filename
      File.join(@compilation_config["pdf_dir"], @compilation.relative_path, 
        "#{@compilation.name}-score")
    end
    
    def midi_filename(mvt)
      if mvt.nil? || mvt.empty?
        mvt = 'score'
      end
      File.join(@compilation_config["midi_dir"], @compilation.relative_path, mvt)
    end
    
    def movement_config(mvt)
      c = super(mvt)
      c["movements"][mvt]["title"] = @work.config["compiled_movement_title"]
      c
    end
    
    def render_movement(mvt)
      @work = Work.new(mvt["work"], @compilation.clean_config)
      @config = @work.config
      @work.config["compiled_movement_title"] = mvt["title"]
      super(mvt["movement"])
    end
  end
end


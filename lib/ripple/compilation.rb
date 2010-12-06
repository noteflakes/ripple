module Ripple
  class Compilation
    attr_reader :config, :path
    
    def initialize(path, config = {})
      if path.nil?
        calculate_fast_compile(config)
      else
        @path = File.expand_path(path)
        @path += ".yml" if @path !~ /\.yml$/
        @config = config.deep_merge(compilation_config)
      end
      qualify_all_movements
      compute_movement_titles
    end
    
    def qualify_movement(work, mvt)
      found = Dir["#{work}/*"].select do |entry|
        if File.directory?(entry)
          n = File.basename(entry)
          (n == mvt) || ((n =~ /^(\d+)/) && ($1.to_i(10) == mvt.to_i))
        end
      end.first
      found && File.basename(found)
    end
    
    def qualify_all_movements
      @config["movements"].each do |m|
        mvt = m["movement"]
        if mvt =~ /(.+)#(.+)/
          m["work"] = $1
          m["movement"] = qualify_movement($1, $2)
          unless m["movement"]
            raise RippleError, "Invalid movement specified: #{mvt}. Check work and movement refs."
          end
        end
        if m["work"].nil?
          raise RippleError, "Missing work specification in config file (#{m["movement"]})"
        end
      end
    end
    
    def compute_movement_titles
      @config["movements"].each_with_index do |m, i|
        w = Work.new(m["work"], clean_config)
        mvt = (m["movement"] =~ /^(\d+)\-(.+)/) ? 
          "#{$1.to_i} - #{$2.titlize(true)}" : m["movement"]
        m["title"] ||= "%d. %s/%s" % [i + 1, w.name, mvt]
      end
    end
    
    def calculate_fast_compile(config)
      @path = File.expand_path("compilations/adhoc.yml")
      @config = config; @config.deep = true
      mvts = @config["fast-compile"].inject([]) do |m, specifier|
        if specifier =~ /(.+)#(.+)/
          work = $1
          if mvt = qualify_movement(work, $2)
            m << {
              "work" => work,
              "movement" => mvt
            }
          end
        else
          Dir["#{work}/*"].each do |entry|
            if File.directory?(entry)
              m << {
                "work" => work,
                "movement" => File.basename(entry)
              }
            end
          end
        end
        m
      end
      @config["movements"] = mvts
    end
    
    def name
      n = (@path =~ /([^\/]+)$/) && $1
      n = (n =~ /^(.+)\.yml$/) && $1
    end
    
    def compilation_config
      load_yaml(@path)
    end
    
    def clean_config
      @config.reject {|k, v| k == "movements" || k == "compile"}
    end
    
    def relative_path
      root = File.expand_path(config["source"])
      p = (path =~ /^(.+)\.yml$/) && $1
      p =~ /^#{root}\/(.+)$/ ? $1 : "."
    end
    
    def all_parts
      # for now return an empty array. later we'll go over all
      # movements and compute a union
      compilation_config["parts"] ? compilation_config["parts"].keys : []
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
      
      parts.each {|p| CompilationPart.new(p, self).process} if do_parts
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
      c = super(mvt); c.deep = true
      c["movements/#{mvt}/title"] = @work.config["compiled_movement_title"]
      c["compiled"] = true
      c["breaks"] = @config["breaks"]
      c["include_toc"] = true
      c
    end
    
    def render_movement(mvt)
      @work = Work.new(mvt["work"], @compilation.clean_config)
      @config = @work.config
      @work.config["compiled_movement_title"] = mvt["title"]
      @work.config["breaks"] = mvt["score_breaks"]
      super(mvt["movement"])
    end
    
    def render(mvts = nil)
      mvts ||= movements
      music = mvts.inject("") {|m, mvt| m << render_movement(mvt)}
      @config = @compilation_config.deep_merge("part" => @part)
      @config["include_toc"] = true
      Templates.render_score(music, @config)
    end
  end
  
  class CompilationPart < Part
    def initialize(part, compilation)
      @part = part
      @compilation = compilation
      @compilation_config = compilation.config
      @work = compilation
      @config = compilation.config
    end
    
    def movements
      @compilation.config["movements"]
    end
    
    def ly_filename
      File.join(@config["ly_dir"], @compilation.relative_path, "#{@part}.ly")
    end
    
    def pdf_filename
      File.join(@config["pdf_dir"], @compilation.relative_path, "#{@compilation.name}-#{@part}")
    end

    def movement_config(mvt)
      c = super(mvt); c.deep = true
      c["movements/#{mvt}/title"] = @work.config["compiled_movement_title"]
      c["compiled"] = true
      if part_config = @config["parts"][@part]
        c = c.deep_merge(part_config).deep_merge("parts" => {@part => part_config})
      end
      c["breaks"] = @config["breaks"]#@config["parts/#{@part}/breaks"]
      c["include_toc"] = true
      c
    end
    
    def render_movement(mvt)
      @work = Work.new(mvt["work"], @compilation.clean_config)
      @config = @work.config.deep_merge(mvt).deep_merge("part" => @part)
      @config["parts/#{@part}/breaks"] = nil
      if part_config = mvt["parts"] && mvt["parts"][@part]
        @config = @config.deep_merge(part_config)
      end
      @config["mode"] = :part
      @work.config["compiled_movement_title"] = mvt["title"]
      super(mvt["movement"])
    end
    
    def render
      mvts = movements
      if @config["unified_movements"]
        music = render_unified_movements(mvts)
      else
        music = mvts.inject("") {|m, mvt| m << render_movement(mvt)}
      end
      @config = @compilation_config.deep_merge("part" => @part)
      @config["include_toc"] = true
      @config["mode"] = :part
      Templates.render_part(music, @config)
    end
  end
end


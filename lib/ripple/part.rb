module Ripple
  class Part
    include Syntax
    
    def initialize(part, work)
      @part = part; @work = work
      @config = work.config.merge("part" => part)
    end
    
    def movement_music_file(part, mvt, config)
      part = config.lookup("parts/#{part}/source") || part
      Dir[File.join(@work.path, mvt, "#{part}.rpl"), 
        File.join(@work.path, mvt, "#{part}.ly")].first
    end
    
    def movement_lyrics_files(part, mvt, config)
      case lyrics = config.lookup("parts/#{part}/lyrics")
      when nil
        Dir[File.join(@work.path, mvt, "#{part}.lyrics*")].sort
      when 'none'
        []
      when Array
        lyrics.inject([]) {|m, i| m+= Dir[File.join(@work.path, mvt, i)].sort}
      when String
        Dir[File.join(@work.path, mvt, lyrics)].sort
      else
        []
      end
    end
    
    def movement_config(mvt)
      c = YAML.load(IO.read(File.join(@work.path, mvt, "_movement.yml"))) rescue {}
      if mc = @config.lookup("movements/#{mvt}")
        mvt_config = @config.deep_merge(mc).deep_merge(c)
      else
        mvt_config = @config.deep_merge(c)
      end
      mvt_config["movement"] = mvt
      mvt_config
    end
    
    def render_part(parts, mvt, config)
      parts = [parts] unless parts.is_a?(Array)
      output = ''
      parts.each do |p|
        c = config.merge("part" => p)
        music_fn = movement_music_file(p, mvt, c)
        output += Templates.render_staff(load_music(music_fn, :part), c)
        if lyrics = movement_lyrics_files(p, mvt, c)
          lyrics.each {|fn| output += Templates.render_lyrics(IO.read(fn), c)}
        end
        if figures_fn = Dir[File.join(@work.path, mvt, "#{p}.figures")].first
          output += Templates.render_figures(IO.read(figures_fn), c)
        end
      end
      output
    end
    
    def render_movement(mvt)
      c = movement_config(mvt)
      
      before_parts = c.lookup("parts/#{@part}/before_include")
      after_parts = c.lookup("parts/#{@part}/after_include")

      if movement_music_file(@part, mvt, c)
        content = ''
        if before_parts
          content = render_part(before_parts, mvt, c)
        end
        content += render_part(@part, mvt, c)
        if after_parts
          content += render_part(after_parts, mvt, c)
        end
        Templates.render_staff_group(content, c)
      else
        Templates.render_part_tacet(c)
      end
    end
    
    def render
      if m = @config["selected_movements"]
        mvts = m.split(',')
      else
        mvts = @work.movements
      end
      
      music = mvts.inject("") {|m, mvt| m << render_movement(mvt)}
      Templates.render_part(music, @config)
    end
    
    def ly_filename
      File.join(@config["ly_dir"], @work.relative_path, "#{@part}.ly")
    end
    
    def pdf_filename
      File.join(@config["pdf_dir"], @work.relative_path, "#{@part}")
    end
    
    def process
      return if @config.lookup("parts/#{@part}/no_part")
      
      # create ly file
      FileUtils.mkdir_p(File.dirname(ly_filename))
      File.open(ly_filename, 'w') {|f| f << render}
      
      unless @config["no_pdf"]
        FileUtils.mkdir_p(File.dirname(pdf_filename))
        Lilypond.make_pdf(ly_filename, pdf_filename, @config)
      end
    rescue LilypondError
      puts
      puts "Failed to generate #{@part} part."
    end
  end
end

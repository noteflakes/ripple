module Ripple
  class Part
    include Syntax
    
    def initialize(part, work)
      @part = part; @work = work
      @config = work.config.merge("part" => part)
    end
    
    def movement_music_file(mvt, config)
      part = config.lookup("parts/#{@part}/source") || @part
      fn = Dir[File.join(@work.path, mvt, "#{part}.rpl"), 
        File.join(@work.path, mvt, "#{part}.ly")].first
    end
    
    def movement_lyrics_files(mvt, config)
      case lyrics = config.lookup("parts/#{@part}/lyrics")
      when nil
        Dir[File.join(@work.path, mvt, "#{@part}.lyrics*")].sort
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
      mvt_config = @config.deep_merge(c)
      mvt_config["movement"] = mvt
      mvt_config
    end
    
    def render_part(parts, config, mvt)
      parts = [parts] unless parts.is_a?(Array)
      output = ''
      parts.each do |p|
        music_fn = Dir[File.join(@work.path, mvt, "#{p}.ly"),
          File.join(@work.path, mvt, "#{p}.rpl")].first
        output += Templates.render_staff(load_music(music_fn), config)
        if lyrics = Dir[File.join(@work.path, mvt, "#{p}.lyrics*")]
          lyrics.each {|fn| output += Templates.render_lyrics(IO.read(fn), config)}
        end
      end
      output
    end
    
    def render_movement(mvt)
      c = movement_config(mvt)
      
      before_parts = c.lookup("parts/#{@part}/before_include")
      after_parts = c.lookup("parts/#{@part}/after_include")
      part_source = c.lookup("parts/#{@part}/source") || @part
      
      if before_parts || after_parts
        content = ''
        if before_parts
          content = render_part(before_parts, c, mvt)
        end
        content += render_part(part_source, c, mvt)
        if after_parts
          content += render_part(after_parts, c, mvt)
        end
        return Templates.render_staff_group(content, c)
      end
      
      music_fn = movement_music_file(mvt, c)
      lyrics = movement_lyrics_files(mvt, c)
      if music_fn && File.exists?(music_fn)
        c["staff_music"] = load_music(music_fn)
        c["staff_lyrics"] = lyrics.map {|fn| IO.read(fn)}
        Templates.render_part_music(c)
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
      return if @config.lookup("parts/#{@part}/ignore")
      
      # create ly file
      FileUtils.mkdir_p(File.dirname(ly_filename))
      File.open(ly_filename, 'w') {|f| f << render}
      
      return if @config["no_pdf"]
      FileUtils.mkdir_p(File.dirname(pdf_filename))
      Ripple::Lilypond.process(ly_filename, pdf_filename, @config)
    rescue LilypondError
      puts
      puts "Failed to generate #{@part} part."
    end
  end
end

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
      else
        Dir[File.join(@work.path, mvt, lyrics)].sort
      end
    end
    
    def movement_config(mvt)
      c = YAML.load(IO.read(File.join(@work.path, mvt, "_movement.yml"))) rescue {}
      mvt_config = @config.deep_merge(c)
      mvt_config["movement"] = mvt
      mvt_config
    end
    
    def render_movement(mvt)
      c = movement_config(mvt)
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
      
      return if @config["ly_only"]
      FileUtils.mkdir_p(File.dirname(pdf_filename))
      Ripple::Lilypond.process(ly_filename, pdf_filename)
    end
  end
end

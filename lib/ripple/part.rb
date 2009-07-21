module Ripple
  class Part
    include Syntax
    
    def initialize(part, work)
      @part = part; @work = work
      @config = work.config.merge("part" => part)
    end
    
    def movement_music_file(mvt, config)
      part = config.lookup("parts/#{@part}/source") || @part
      fn = File.join(@work.path, mvt, "#{part}.rpl")
      unless File.file?(fn)
        fn = File.join(@work.path, mvt, "#{part}.ly")
      else
        fn
      end
    end
    
    def movement_lyrics_file(mvt, config)
      case lyrics = config.lookup("parts/#{@part}/lyrics")
      when nil
        File.join(@work.path, mvt, "#{@part}.lyrics")
      when 'none'
        nil
      else
        File.join(@work.path, mvt, lyrics)
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
      lyrics_fn = movement_lyrics_file(mvt, c)
      if File.exists?(music_fn)
        c["staff_music"] = load_music(music_fn)
        if lyrics_fn && File.exists?(lyrics_fn)
          c["staff_lyrics"] = IO.read(lyrics_fn)
        end
        Templates.render_part_music(c)
      else
        Templates.render_part_tacet(c)
      end
    end
    
    def render
      mvts = @work.movements
      
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
      
      FileUtils.mkdir_p(File.dirname(pdf_filename))
      Ripple::Lilypond.process(ly_filename, pdf_filename)
    end
  end
end

module Ripple
  class Score
    def initialize(work)
      @work = work
      @config = work.config
    end
    
    def movement_music_file(part, mvt, config)
      part = config.lookup("parts/#{part}/source") || part
      File.join(@work.path, mvt, "#{part}.rly")
    end
    
    def movement_lyrics_file(part, mvt, config)
      case lyrics = config.lookup("parts/#{part}/lyrics")
      when nil
        File.join(@work.path, mvt, "#{part}.lyrics")
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
      
      movement_files = Dir[File.join(@work.path, mvt, '*.rly')]
      parts = []
      
      movement_files.each do |fn|
        p = File.basename(fn, '.rly')
        parts << p
        
        c.set("parts/#{p}/staff_music", IO.read(fn))
        lyrics_fn = File.join(File.dirname(fn), "#{p}.lyrics")
        if File.exists?(lyrics_fn)
          c.set("parts/#{p}/staff_lyrics", IO.read(lyrics_fn))
        end
      end
      
      Templates.render_score_movement(parts, c)
    end
    
    def render
      mvts = @work.movements
      mvts << "" if mvts.empty?
      
      music = mvts.inject("") {|m, mvt| m << render_movement(mvt)}
      Templates.render_score(music, @config)
    end

    def ly_filename
      File.join(@config["ly_dir"], @work.relative_path, "score.ly")
    end
    
    def pdf_filename
      File.join(@config["pdf_dir"], @work.relative_path, "score")
    end
    
    def process
      mvts = @work.movements
      mvts << "" if mvts.empty?
      
      # create ly file
      FileUtils.mkdir_p(File.dirname(ly_filename))
      File.open(ly_filename, 'w') {|f| f << render}
      
      FileUtils.mkdir_p(File.dirname(pdf_filename))
      Ripple::Lilypond.process(ly_filename, pdf_filename)
    end

  end
end
    

module Ripple
  class Score
    include Syntax
    
    def initialize(work)
      @work = work
      @config = work.config
    end
    
    def movement_music_file(part, mvt, config)
      part = config.lookup("parts/#{part}/source") || part
      fn = File.join(@work.path, mvt, "#{part}.rpl")
      unless File.file?(fn)
        fn = File.join(@work.path, mvt, "#{part}.ly")
      else
        fn
      end
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
      
      movement_files = Dir[File.join(@work.path, mvt, '*.rpl'), File.join(@work.path, mvt, '*.ly')]
      parts = []
      
      movement_files.each do |fn|
        p = File.basename(fn, '.*')
        parts << p
        
        c.set("parts/#{p}/staff_music", load_music(fn))
        
        lyrics = Dir[File.join(File.dirname(fn), "#{p}.lyrics*")].sort
        c.set("parts/#{p}/staff_lyrics", lyrics.map {|fn| IO.read(fn)})
      end
      
      Templates.render_score_movement(parts, c)
    end
    
    def render
      if m = @config["selected_movements"]
        mvts = m.split(',')
      else
        mvts = @work.movements
      end
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
      
      # create ly file
      FileUtils.mkdir_p(File.dirname(ly_filename))
      File.open(ly_filename, 'w') {|f| f << render}
      
      return if @config["ly_only"]
      FileUtils.mkdir_p(File.dirname(pdf_filename))
      Ripple::Lilypond.process(ly_filename, pdf_filename)
    end

  end
end
    

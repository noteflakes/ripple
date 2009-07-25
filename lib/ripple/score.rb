module Ripple
  class Score
    include Syntax
    
    def initialize(work)
      @work = work
      @config = work.config
    end
    
    def movement_music_file(part, mvt, config)
      part = config.lookup("parts/#{part}/source") || part
      Dir[File.join(@work.path, mvt, "#{part}.rpl"), 
        File.join(@work.path, mvt, "#{part}.ly")].first
    end
    
    def movement_lyrics_file(part, mvt, config)
      case lyrics = config.lookup("parts/#{part}/lyrics")
      when nil
        Dir[File.join(@work.path, mvt, "#{part}.lyrics*")].sort
      when 'none'
        []
      when Array
        lyrics.inject([]) {|m, i| m+= Dir[File.join(@work.path, mvt, i)].sort}
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
    
    def render_parts(parts, mvt, config)
      parts = [parts] unless parts.is_a?(Array)
      output = ''
      parts.each do |p|
        title = config.lookup("parts/#{p}/title") || p.to_instrument_title
        c = config.merge("part" => p, "staff_name" => title)
        music_fn = movement_music_file(p, mvt, c)
        output += Templates.render_staff(load_music(music_fn), c)
        if lyrics = movement_lyrics_file(p, mvt, c)
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
      
      movement_files = Dir[File.join(@work.path, mvt, '*.rpl'), File.join(@work.path, mvt, '*.ly')]
      parts = []
      movement_files.each do |fn|
        p = File.basename(fn, '.*')
        next if c["parts/#{p}/no_score"]
        parts << p
        # c.set("parts/#{p}/staff_music", load_music(fn))
        # 
        # lyrics = movement_lyrics_file(p, mvt, c)
        # c.set("parts/#{p}/staff_lyrics", lyrics.map {|fn| IO.read(fn)})
      end
      # Templates.render_score_movement(parts, c)

      # determine staff order
      order = c.lookup("score/order") || parts.sort
      parts = order.select {|p| parts.include?(p)}

      content = render_parts(parts, mvt, c)
      Templates.render_staff_group(content, c)
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
      
      return if @config["no_pdf"]
      FileUtils.mkdir_p(File.dirname(pdf_filename))
      Ripple::Lilypond.process(ly_filename, pdf_filename, @config)
    rescue LilypondError
      puts
      puts "Failed to generate score."
    end

  end
end
    

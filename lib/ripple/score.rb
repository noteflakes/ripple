module Ripple
  class Score
    include Syntax
    
    def initialize(work)
      @work = work
      @config = work.config
    end
    
    def movement_music_file(part, mvt, config)
      part = config["parts/#{part}/source"] || part
      Dir[File.join(@work.path, mvt, "#{part}.rpl"), 
        File.join(@work.path, mvt, "#{part}.ly")].first
    end
    
    def movement_lyrics_file(part, mvt, config)
      case lyrics = config["parts/#{part}/lyrics"]
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
      if mc = @config["movements/#{mvt}"]
        mvt_config = @config.deep_merge(mc).deep_merge(c)
      else
        mvt_config = @config.deep_merge(c)
      end
      mvt_config["movement"] = mvt
      mvt_config
    end
    
    def render_parts(parts, mvt, config)
      parts = [parts] unless parts.is_a?(Array)
      output = ''
      parts.each do |p|
        title = config["parts/#{p}/title"] || p.to_instrument_title
        c = config.merge("part" => p, "staff_name" => title)
        music_fn = movement_music_file(p, mvt, c)
        mode = @config["midi"] ? :midi : :score
        output += Templates.render_staff(music_fn, load_music(music_fn, mode), c)
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
      
      movement_files = Dir[
        File.join(@work.path, mvt, '*.rpl'), 
        File.join(@work.path, mvt, '*.ly')
      ]
      parts = []
      movement_files.each do |fn|
        p = File.basename(fn, '.*')
        next if c["parts/#{p}/no_score"]
        parts << p
      end

      # determine staff order
      order = c["score/order"] || parts.sort
      parts = order.select {|p| parts.include?(p)}

      content = render_parts(parts, mvt, c)
      Templates.render_staff_group(content, c)
    end
    
    def movements
      if m = @config["selected_movements"]
        mvts = m.split(',')
      else
        mvts = @work.movements
      end
      mvts << "" if mvts.empty?
      mvts
    end
    
    def render(mvts = nil)
      mvts ||= movements
      
      music = mvts.inject("") {|m, mvt| m << render_movement(mvt)}
      Templates.render_score(music, @config)
    end

    def ly_filename(mvt = nil)
      File.join(@config["ly_dir"], @work.relative_path, 
        (mvt ? "#{mvt}.ly" : "score.ly"))
    end
    
    def pdf_filename
      File.join(@config["pdf_dir"], @work.relative_path, "score")
    end
    
    def midi_filename(mvt)
      File.join(@config["midi_dir"], @work.relative_path, mvt)
    end
    
    def process
      if @config["midi"]
        movements.each do |m|
          fn = ly_filename(m); mfn = midi_filename(m)
          FileUtils.mkdir_p(File.dirname(fn))
          File.open(fn, 'w') {|f| f << render([m])}
          FileUtils.mkdir_p(File.dirname(mfn))
          Lilypond.make_midi(fn, mfn, @config)
        end
      else
        # create ly file
        FileUtils.mkdir_p(File.dirname(ly_filename))
        File.open(ly_filename, 'w') {|f| f << render}

        unless @config["no_pdf"]
          FileUtils.mkdir_p(File.dirname(pdf_filename))
          Lilypond.make_pdf(ly_filename, pdf_filename, @config)
        end
      end
    rescue LilypondError
      puts
      puts "Failed to generate score."
    end

  end
end
    

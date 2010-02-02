module Ripple
  class Score
    include Syntax
    
    def initialize(work, config = nil)
      @work = work
      @config = config || work.config
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
    
    def render_part_music(part, mvt, config)
      mode = @config["midi"] ? :midi : :score
      mvts = mvt.is_a?(Array) ? mvt : [mvt]
      music_fn = ""
      music = mvts.inject("") do |m, mvt|
        music_fn = movement_music_file(part, mvt, config)
        m << load_music(music_fn, mode, config)
      end
      Templates.render_staff(music_fn, music, config)
    end
    
    def render_part_lyrics(part, mvt, config)
      output = ""
      if lyrics = movement_lyrics_file(part, mvt, config)
        lyrics.each {|fn| output += Templates.render_lyrics(IO.read(fn), config)}
      end
      output
    end
    
    def render_part_figures(part, mvt, config)
      output = ""
      if !config["score/supress_figures"] && figures_fn = Dir[File.join(@work.path, mvt, "#{part}.figures")].first
        output += Templates.render_figures(IO.read(figures_fn), config)
      end
      output
    end
    
    def render_parts(parts, mvt, config)
      parts = [parts] unless parts.is_a?(Array)
      output = ''
      parts.each do |p|
        title = config["parts/#{p}/title"] || p.to_instrument_title
        c = config.merge("part" => p, "staff_name" => title)
        output += render_part_music(p, mvt, c)
        output += render_part_lyrics(p, mvt, c)
        output += render_part_figures(p, mvt, c)
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
      c["score/rendered_parts"] = parts

      content = render_parts(parts, mvt, c)
      Templates.render_movement(content, c)
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
      @config["include_toc"] = (mvts.size > 1) && !(@config["toc"] == false)
      
      music = mvts.inject("") {|m, mvt| m << render_movement(mvt)}
      Templates.render_score(music, @config)
    end

    def ly_filename(mvt = nil)
      File.join(@config["ly_dir"], @work.relative_path, 
        (mvt ? "#{mvt}.ly" : "score.ly"))
    end
    
    def pdf_filename
      File.join(@config["pdf_dir"], @work.relative_path, "#{@work.name}-score")
    end
    
    def midi_filename(mvt)
      if mvt.nil? || mvt.empty?
        mvt = 'score'
      end
      File.join(@config["midi_dir"], @work.relative_path, mvt)
    end
    
    def process
      @config["mode"] = :score

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
    

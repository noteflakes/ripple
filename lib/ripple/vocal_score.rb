module Ripple
  class VocalScore < Score
    def render_combined(parts, mvt, config)
      titles = []
      content = parts.inject('') do |m, p| 
        titles << (config["parts/#{p}/title"] || p.to_instrument_title)
        c = config.merge("part" => p)
        music_fn = movement_music_file(p, mvt, c)
        m += load_music(music_fn, :score, c)
      end
      Templates.render_combined(parts, titles, content, config)
    end
    
    def render_parts(parts, mvt, config)
      parts = [parts] unless parts.is_a?(Array)
      output = ''
      parts.each do |p|
        if p.is_a?(Array)
          output += render_combined(p, mvt, config)
        else
          title = config["parts/#{p}/title"] || p.to_instrument_title
          c = config.merge("part" => p, "staff_name" => title)
          music_fn = movement_music_file(p, mvt, c)
          mode = @config["midi"] ? :midi : :score
          output += Templates.render_staff(music_fn, load_music(music_fn, mode, c), c)
          if lyrics = movement_lyrics_file(p, mvt, c)
            lyrics.each {|fn| output += Templates.render_lyrics(IO.read(fn), c)}
          end
          if figures_fn = Dir[File.join(@work.path, mvt, "#{p}.figures")].first
            output += Templates.render_figures(IO.read(figures_fn), c)
          end
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
      order = c["vocal/order"] || parts.sort
      parts = order.inject([]) do |m, p|
        if p.is_a?(Array)
          m << p.select {|p2| parts.include?(p2)}
        else
          m << p if parts.include?(p)
        end
        m
      end
      c["score/rendered_parts"] = parts

      content = render_parts(parts, mvt, c)
      Templates.render_movement(content, c)
    end
    
    def ly_filename(mvt = nil)
      File.join(@config["ly_dir"], @work.relative_path, 
        (mvt ? "#{mvt}.ly" : "vocal.ly"))
    end
    
    def pdf_filename
      File.join(@config["pdf_dir"], @work.relative_path, "vocal")
    end
    
    def process
      @config["mode"] = :score

      # create ly file
      FileUtils.mkdir_p(File.dirname(ly_filename))
      File.open(ly_filename, 'w') {|f| f << render}

      unless @config["no_pdf"]
        FileUtils.mkdir_p(File.dirname(pdf_filename))
        Lilypond.make_pdf(ly_filename, pdf_filename, @config)
      end
    rescue LilypondError
      puts
      puts "Failed to generate score."
    end
  end
end

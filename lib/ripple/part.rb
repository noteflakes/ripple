module Ripple
  class Part
    include Syntax
    
    def initialize(part, work)
      @part = part; @work = work
      @config = work.config.merge("part" => part)
    end
    
    def movement_music_file(part, mvt, config)
      part = config["parts/#{part}/source"] || part
      Dir[File.join(@work.path, mvt, "#{part}.rpl"), 
        File.join(@work.path, mvt, "#{part}.ly")].first
    end
    
    def movement_lyrics_files(part, mvt, config)
      case lyrics = config["parts/#{part}/lyrics"]
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
      if mc = @config["movements/#{mvt}"]
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
        title = (config["parts/#{@part}/before_include"] || config["parts/#{@part}/after_include"]) ?
          config["parts/#{p}/title"] || p.to_instrument_title : nil
        c = config.merge(config["parts/#{@part}"] || {}).merge("part" => p, "staff_name" => title)
        music_fn = movement_music_file(p, mvt, c)

        if !c["parts/#{@part}/hide_figures"] && figures_fn = Dir[File.join(@work.path, mvt, "#{p}.figures")].first
          figures = IO.read(figures_fn)
          # check if should embed figures in staff
          c["figures"] = figures if c["embed_figures"]
        end

        output += Templates.render_staff(music_fn, load_music(music_fn, :part, c), c)
        if lyrics = movement_lyrics_files(p, mvt, c)
          lyrics.each {|fn| output += Templates.render_lyrics(IO.read(fn), c)}
        end
        if figures && !c["embed_figures"]
          # if not embedding figures, they are rendered separately
          output += Templates.render_figures(IO.read(figures_fn), c)
        end
      end
      output
    end
    
    def render_movement(mvt)
      c = movement_config(mvt)
      
      if c["parts/#{@part}/score_in_part"]
        Score.new(@work, c.merge('mode' => :score)).render_movement(mvt)
      elsif movement_music_file(@part, mvt, c)
        before_parts = c["parts/#{@part}/before_include"]
        after_parts = c["parts/#{@part}/after_include"]
        content = ''
        if before_parts
          content = render_part(before_parts, mvt, c.merge("aux_staff" => true))
        end
        content += render_part(@part, mvt, c)
        if after_parts
          content += render_part(after_parts, mvt, c.merge("aux_staff" => true))
        end
        Templates.render_movement(content, c.merge("aux_staves" => (before_parts || after_parts)))
      else
        Templates.render_part_tacet(c)
      end
    end
    
    def render_unified_movements(mvts)
      puts "unified movements ..."
      last_mvt = mvts.last
      music = mvts.inject("") do |m, mvt|
        c = movement_config(mvt)
        music_fn = movement_music_file(@part, mvt, c)
        m << load_music(music_fn, :part, c)
        m << " \\bar \"||\"\n\n" unless mvt == last_mvt
        m
      end
      c = movement_config("")
      combined = Templates.render_staff("Combined movements", music, c)
      Templates.render_movement(combined, c)
    end
    
    def render
      if m = @config["selected_movements"]
        mvts = m.split(',')
      else
        mvts = @work.movements
      end
      
      if @config["unified_movements"]
        music = render_unified_movements(mvts)
      else
        music = mvts.inject("") {|m, mvt| m << render_movement(mvt)}
      end
      Templates.render_part(music, @config)
    end
    
    def ly_filename
      File.join(@config["ly_dir"], @work.relative_path, "#{@part}.ly")
    end
    
    def pdf_filename
      File.join(@config["pdf_dir"], @work.relative_path, "#{@work.name}-#{@part}")
    end
    
    def process
      return if @config["parts/#{@part}/no_part"]
      
      @config["mode"] = :part

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

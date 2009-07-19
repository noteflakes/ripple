require 'erb'

module Ripple
  class Part
    def initialize(part, work)
      @part = part; @work = work
      @config = work.config
      @config["part"] = part
    end
    
    def movement_file(mvt)
      fn = File.join(@work.path, mvt, "#{@part}.rly")
      # here we also search for more general part files
      # e.g. violino1 parts will include stuff from _violino.rly files
      if !File.exists?(fn) && @part =~ /^(.+)\d$/ &&
        fn = File.join(@work.path, mvt, "_#{$1}.rly")
      end
      fn
    end
    
    def render_movement(mvt)
      c = @config.merge("movement" => mvt)
      fn = movement_file(mvt)
      if File.exists?(fn)
        c["staff_music"] = IO.read(fn)
        Templates.render_part_music(c)
      else
        Templates.render_part_tacet(c)
      end
    end
    
    def render
      music = @work.movements.inject("") {|m, mvt| m << render_movement(mvt)}
      Templates.render_part(music, @config)
    end
    
    def ly_filename
      File.join(@config["ly_dir"], @work.relative_path, "#{@part}.ly")
    end
    
    def pdf_filename
      File.join(@config["pdf_dir"], @work.relative_path, "#{@part}")
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

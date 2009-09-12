require 'erb'

module Ripple
  module Templates
    TEMPLATES_DIR = File.join(File.dirname(__FILE__), 'templates')
    
    def self.template(name)
      ERB.new IO.read(File.join(TEMPLATES_DIR, "#{name}.ly"))
    end

    DEFAULT_ENDING_BAR = "|."
    
    def self.part_clef(config)
      part = config["part"]
      case c = config["parts/#{part}/clef"]
      when 'none': nil
      else
        c
      end
    end
    
    def self.midi_instrument(config)
      part = config["part"]
      case i = config["parts/#{part}/midi_instrument"]
      when nil
        # generate midi instrument name from part name
        (i =~ /([^\d]+)(\d+)/) ? $1 : i
      else
        i
      end
    end
    
    def self.show_ambitus(config)
      config["show_ambitus"] || config["parts/#{config["part"]}/show_ambitus"]
    end
    
    def self.auto_beam_off(config)
      config["parts/#{config["part"]}/auto_beam"] == false
    end
    
    def self.end_bar(config)
      case config["end_bar"]
      when nil: "\\bar \"#{DEFAULT_ENDING_BAR}\""
      when 'none': ''
      else
        "\\bar \"#{config["end_bar"]}\""
      end
    end
    
    def self.render_movement(content, config)
      template(:movement).result(binding)
    end

    def self.render_staff(fn, content, config)
      template(:staff).result(binding)
    end

    def self.render_lyrics(content, config)
      template(:lyrics).result(binding)
    end

    def self.render_figures(content, config)
      template(:figures).result(binding)
    end

    def self.render_part_tacet(config)
      template(:tacet).result(binding)
    end
    
    def self.render_part(content, config)
      # include files
      include = config["include"] || []
      if config["part_include"]
        include += config["part_include"]
      end
      
      template(:part).result(binding)
    end
    
    def self.render_score(content, config)
      # include files
      include = config["include"] || []
      if config["score_include"]
        include += config["score_include"]
      end
      
      toc = config["multi_movement"] && !(config["toc"] == false)
      
      template(:score).result(binding)
    end
  end
end
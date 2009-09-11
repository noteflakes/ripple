require 'erb'

module Ripple
  module Templates
    TEMPLATES_DIR = File.join(File.dirname(__FILE__), 'templates')
    
    def self.template(name)
      ERB.new IO.read(File.join(TEMPLATES_DIR, "#{name}.ly"))
    end

    DEFAULT_ENDING_BAR = "|."
    
    def self.part_clef(data)
      part = data["part"]
      case c = data["parts/#{part}/clef"]
      when 'none': nil
      else
        c
      end
    end
    
    def self.midi_instrument(data)
      part = data["part"]
      case i = data["parts/#{part}/midi_instrument"]
      when nil
        # generate midi instrument name from part name
        (i =~ /([^\d]+)(\d+)/) ? $1 : i
      else
        i
      end
    end
    
    def self.show_ambitus(data)
      data["show_ambitus"] || data["parts/#{data["part"]}/show_ambitus"]
    end
    
    def self.auto_beam_off(data)
      data["parts/#{data["part"]}/auto_beam"] == false
    end
    
    def self.end_bar(data)
      case data["end_bar"]
      when nil: "\\bar \"#{DEFAULT_ENDING_BAR}\""
      when 'none': ''
      else
        "\\bar \"#{data["end_bar"]}\""
      end
    end
    
    def self.render_staff_group(content, data)
      template(:staff_group).result(binding)
    end

    def self.render_staff(fn, content, data)
      template(:staff).result(binding)
    end

    def self.render_lyrics(content, data)
      template(:lyrics).result(binding)
    end

    def self.render_figures(content, data)
      template(:figures).result(binding)
    end

    def self.render_part_tacet(data)
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
      
      template(:score).result(binding)
      t.result(binding)
    end
  end
end
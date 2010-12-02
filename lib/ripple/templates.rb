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
      when 'none'
        nil
      else
        c
      end
    end
    
    def self.combined_part_clef(parts, config)
      clefs = parts.map {|p| config["parts/#{p}/clef"]}.uniq
      case clefs.size
      when 0
        'treble'
      when 1
        clefs[0]
      else
        clefs.include?('bass') ? 'bass' : clefs[0]
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
    
    def self.hidden_staff?(config)
      return false if config["mode"] == :part || !config["score/auto_hide"]
      (config["score/auto_hide"] == true) || config["score/auto_hide"].include?(config["part"])
    end
    
    def self.show_ambitus(config)
      config["show_ambitus"] || config["parts/#{config["part"]}/show_ambitus"]
    end
    
    def self.auto_beam_off(config)
      config["parts/#{config["part"]}/auto_beam"] == false
    end
    
    def self.end_bar(config)
      case config["end_bar"]
      when nil
        "\\bar \"#{DEFAULT_ENDING_BAR}\""
      when 'none'
        ''
      else
        "\\bar \"#{config["end_bar"]}\""
      end
    end
    
    def self.staff_groups(parts, config)
      return nil unless groups = config["score/groups"]
      grouped = parts.map do |p|
        if config["parts/#{p}/keyboard"]
          ['organo.1', 'organo.2']
          # {'brace' => ['organo.1', 'organo.2']}
        else
          p
        end
      end.flatten

      # groups should be an array of hashes
      groups.each do |g| 
        kind = g.keys.first
        # select the group parts that appear in the movement
        group_parts = g.values.first.select {|p| parts.include?(p)}

        # group only if more than one part in the group appears in the movement
        if (group_parts.size > 1) && (idx = grouped.array_index(group_parts))
          before = grouped[0...idx]
          after = grouped[(idx + group_parts.size)..-1]
          grouped = before + [{kind => group_parts}] + after
        end
      end
      
      grouped
    end
    
    SYSTEM_START = {
      "brace" => "SystemStartBrace",
      "bracket" => "SystemStartBracket"
    }
    
    # renders a systemStartDelimiterHierarchy expression
    def self.staff_hierarchy(parts, config)
      groups = staff_groups(parts, config)
      expr = groups.map do |g|
        if g.is_a?(Hash)
          "(#{SYSTEM_START[g.keys.first]} #{g.values.first.join(' ')})"
        else
          g
        end
      end
      "#'(SystemStartBracket #{expr.join(' ')})"
    end
    
    def self.should_break(config)
      if config["compiled"]
        return config["breaks"] && config["breaks"] > 0
      end
      breaks = case config["mode"]
      when :part
        config["parts/#{config["part"]}/breaks"]
      else
        (config["score_mode"] == :vocal) ? config["vocal/breaks"] : config["score/breaks"]
      end
      breaks = [breaks] unless breaks.is_a?(Array)
      breaks.include?(config["movement"])
    end
    
    def self.movement_blank_pages(config)
      if config["compiled"]
        return config["breaks"].to_i - 1
      end
      breaks = (config["mode"] == :part) ?
        config["parts/#{config["part"]}/breaks"] :
        config["score/breaks"]
      breaks = [breaks] unless breaks.is_a?(Array)
      count = breaks.count(config["movement"])
      (count > 1) ? (count - 1) : 0
    end
    
    def self.smart_page_turns(config)
      v = (config["mode"] == :part) && 
        (config["smart_page_turn"] || config["parts/#{config["part"]}/smart_page_turn"])
      v = "1 1" if v == true
      v
    end
    
    SOLO_TAG = ['soloText', 'soloIIText', 'soloIIIText', 'soloIVText']
    
    def self.combined_solo_text(idx, title)
      "\\set Staff.#{SOLO_TAG[idx]} = #\"#{title}\""
    end
    
    def self.render_combined(parts, titles, content, config)
      template(:combined).result(binding)
    end
    
    def self.render_movement(content, config)
      template(:movement).result(binding)
    end
    
    def self.get_transposition(config)
      if config['midi'] && (t = config["parts/#{config["part"]}/midi_transpose"])
        t
      else
        config["parts/#{config["part"]}/transpose"]
      end
    end
    
    def self.transpose(content, config)
      if t = get_transposition(config)
        t = Ripple::Syntax.cvt(t)
        "\\transpose #{t} { #{content} }"
      else
        content
      end
    end

    def self.render_staff(fn, content, config)
      content = transpose(content, config)
      template(:staff).result(binding)
    end
    
    def self.render_keyboard_part(content, config)
      template(:keyboard_part).result(binding)
    end
    
    def self.staff_id(config)
      name = config["staff_name"]
      name = 'part' if name.nil? || name.empty?
      "#{name.gsub(/[^a-z0-9]/i, '')}Staff"
    end
    
    def self.movement_title(config)
      mvt = config["movement"]
      title = config["movement_title"] || config["movements/#{mvt}/title"] || mvt
      title.to_movement_title
    end
    
    def self.part_source(config)
      config["parts/#{config["part"]}/source"]
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
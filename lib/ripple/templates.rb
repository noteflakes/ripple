require 'erb'

module Ripple
  module Templates
    DEFAULT_ENDING_BAR = "|."
    
    TREBLE = 'treble'
    TREBLE_8 = 'treble_8'
    ALTO = 'alto'
    BASS = 'bass'
    
    DEFAULT_CLEF = {
      'soprano' => TREBLE,
      'alto' => TREBLE,
      'tenore' => TREBLE_8,
      'tenor' => TREBLE_8,
      'basso' => BASS,
      'bass' => BASS,
      'violin' => TREBLE,
      'violino' => TREBLE,
      'violin1' => TREBLE,
      'violin2' => TREBLE,
      'violino1' => TREBLE,
      'violino2' => TREBLE,
      'violini' => TREBLE,
      'viola' => ALTO,
      'fagott' => BASS,
      'fagotto' => BASS,
      'violoncello' => BASS,
      'cello' => BASS,
      'continuo' => BASS,
      'organo' => BASS,
      'oboe' => TREBLE,
      'oboe1' => TREBLE,
      'oboe2' => TREBLE
    }
    
    def self.part_clef(data)
      part = data["part"]
      data.lookup("parts/#{part}/clef") || DEFAULT_CLEF[part]
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
      t = ERB.new <<-EOF
\\score {
  \\new StaffGroup <<
  <%= data["part_macro"] %>
<%= content %>
  >>
  \\header { piece = "<%= data["movement"].to_movement_title %>" }
}

EOF
      t.result(binding)      
    end

    def self.render_staff(content, data)
      t = ERB.new <<-EOF
\\new Staff {
  <% if name = data["staff_name"] %>\\set Staff.instrumentName = #"<%= name %>"<% end %>
  <% if clef = part_clef(data) %>\\clef "<%= clef %>"<% end %>
  <%= content %>
  <%= end_bar(data) %>
}
EOF
      t.result(binding)
    end

    def self.render_lyrics(content, data)
      t = ERB.new <<-EOF
\\addlyrics {
  \\lyricmode {
    <%= content %>
  }
}
EOF
      t.result(binding)
    end

    def self.render_figures(content, data)
      t = ERB.new <<-EOF
\\figures {
<%= content %>
}
EOF
      t.result(binding)
    end

    def self.render_part_tacet(data)
      t = ERB.new <<-EOF
\\markup {
  <%= data["movement"].to_movement_title %> - tacet
}
EOF
      t.result(binding)
    end
    
    def self.render_part(content, config)
      # include files
      include = config["include"] || []
      if config["part_include"]
        include += config["part_include"]
      end
      
      t = ERB.new <<-EOF
<% include.each do |inc| %>\\include "<%= inc %>"
<% end %>
\\header {
  title = "<%= config["title"] %>"
  composer = "<%= config["composer"] %>"
  instrument = "<%= config.lookup("parts/#{config["part"]}/title") || 
    config["part"].to_instrument_title %>"
}

<%= content %>

\\version "2.12.2"

EOF
      t.result(binding)
    end
    
    def self.render_score(content, config)
      # include files
      include = config["include"] || []
      if config["score_include"]
        include += config["score_include"]
      end

      t = ERB.new <<-EOF
<% include.each do |inc| %>\\include "<%= inc %>"
<% end %>
\\header {
  title = "<%= config["title"] %>"
  composer = "<%= config["composer"] %>"
}

<%= content %>

\\version "2.12.2"

EOF
      t.result(binding)
    end
  end
end
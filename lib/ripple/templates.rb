module Ripple
  module Templates
    def self.render_part_music(data)
      t = ERB.new <<-EOF
\\score {
  <<
  \\prepare
  \\new Staff {
    <% if clef = data.lookup("parts/#{data["part"]}/clef") %>
      \\clef "<%= clef %>"
    <% end %>
    <%= data["staff_music"] %>
  }
  <% if data["staff_lyrics"] %>
    \\addlyrics {
      \\lyricmode {
        <%= data["staff_lyrics"] %>
      }
    }
  <% end %>
  >>
  \\header { piece = "<%= data["movement"].to_movement_title %>" }
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
    
    def self.render_score_staff(data)
      t = ERB.new <<-EOF
\\new Staff {
  \\set Staff.instrumentName = #"<%= data.lookup("parts/#{data["part"]}/title") || 
    data["part"].to_instrument_title %>"
  <%= data["staff_music"] %>
}
<% if data["staff_lyrics"] %>
  \\addlyrics {
    \\lyricmode {
      <%= data["staff_lyrics"] %>
    }
  }
<% end %>
EOF
      t.result(binding)
    end
    
    def self.render_score_movement(parts, data)
      order = config.lookup("score/order") || parts.sort
      music = order.inject("") do |m, p|
        if parts.include?(p)
          staff_music = config.lookup("parts/#{p}/staff_music")
          staff_lyrics = config.lookup("parts/#{p}/staff_lyrics")
          d = data.merge('part' => p, 'staff_music' => staff_music, 
            'staff_lyrics' => staff_lyrics)
          m << render_score_staff(d)
        end
        m
      end
      t = ERB.new <<-EOF
\\score {
  \\new StaffGroup <<
<%= music %>
  >>
  \\header { piece = "<%= data["movement"].to_movement_title %>" }
}

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
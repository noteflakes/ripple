module Ripple
  module Templates
    def self.render_part_music(data)
      t = ERB.new <<-EOF
\\score {
  <<
  \\prepare
  \\new Staff {
    <%= data["staff_music"] %>
  }
  <% if data["staff_lyrics"] %>
    \\addlyrics {
      <%= data["staff_lyrics"] %>
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
        include << config["part_include"]
      end
      
      t = ERB.new <<-EOF
<% include.each do |inc| %>
\\include "<%= inc %>"
<% end %>
\\header {
  title = "<%= config["title"] %>"
  composer = "<%= config["composer"] %>"
  instrument = "<%= config["part"].capitalize %>"
}

<%= content %>

\\version "2.12.2"

EOF
      t.result(binding)
    end
  end
end
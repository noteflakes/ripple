<% include.each do |inc| %>\include "<%= inc %>"
<% end %>
\header {
  title = <%= piece_title(config) %>
  composer = "<%= config["composer"] %>"
  instrument = "<%= config["parts/#{config["part"]}/title"] || 
    config["part"].to_instrument_title %>"
}

<%= content %>

\version "2.12.2"

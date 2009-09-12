<% include.each do |inc| %>\include "<%= inc %>"
<% end %>
\header {
	<% if config["title"] %>
  	title = <%= config["title"].inspect %>
	<% end %>
	<% if config["subtitle"] %>
		subtitle = <%= config["subtitle"].inspect %>
	<% end %>
  composer = "<%= config["composer"] %>"
  instrument = "<%= config["parts/#{config["part"]}/title"] || 
    config["part"].to_instrument_title %>"
}

<%= content %>

\version "2.12.2"


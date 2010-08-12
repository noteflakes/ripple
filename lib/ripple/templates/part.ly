<% include.each do |inc| %>\include "<%= inc %>"
<% end %>
\book {
  <% if config["include_toc"] %>
  	\markuplines \table-of-contents
  <% end %>
	\header {
		<% if config["title"] %>
	  	title = <%= config["title"].ly_inspect %>
		<% end %>
		<% if config["subtitle"] %>
			subtitle = <%= config["subtitle"].ly_inspect %>
		<% end %>
		<% if config["subsubtitle"] %>
			subsubtitle = <%= config["subsubtitle"].ly_inspect %>
		<% end %>
	  composer = "<%= config["composer"] %>"
	  instrument = "<%= config["parts/#{config["part"]}/title"] || 
      config["part"].to_instrument_title %>"
	}

	\bookpart {
		\pageBreak
		<%= content %>
	}
}

\version "2.12.3"


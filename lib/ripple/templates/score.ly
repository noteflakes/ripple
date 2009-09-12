<% include.each do |inc| %>\include "<%= inc %>"
<% end %>

\book {
<% if config["include_toc"] %>
	\markuplines \table-of-contents
<% end %>
	\header {
		<% if config["title"] %>
	  	title = <%= config["title"].inspect %>
		<% end %>
		<% if config["subtitle"] %>
			subtitle = <%= config["subtitle"].inspect %>
		<% end %>
	  composer = "<%= config["composer"] %>"
	}

	\bookpart {
		\pageBreak
		<%= content %>
	}
}

\version "2.12.2"

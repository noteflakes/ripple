<% include.each do |inc| %>\include "<%= inc %>"
<% end %>

\book {
<% if config["include_toc"] %>
	\markuplines \table-of-contents
	\pageBreak
<% end %>
	\header {
	  title = <%= piece_title(config) %>
	  composer = "<%= config["composer"] %>"
	}

	<%= content %>
}

\version "2.12.2"

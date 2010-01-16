<% include.each do |inc| %>\include "<%= inc %>"
<% end %>

<% if staff_size = config["score/staff_size"] %>
#(set-global-staff-size <%= staff_size %>)
<% end %>

<% if config["score/hide_empty_staves"] %>
\layout {
  \context { 
    % add the RemoveEmptyStaffContext that erases rest-only staves
    \RemoveEmptyStaffContext 
  }
  <% if config["score/hide_empty_staves"].to_s == 'all' %>
  \context {
    \Score
    % Remove all-rest staves also in the first system
    \override VerticalAxisGroup #'remove-first = ##t
  }
  <% end %>
}
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
	  composer = "<%= config["composer"] %>"
	}

	\bookpart {
		\pageBreak
		<%= content %>
	}
}

\version "2.12.3"

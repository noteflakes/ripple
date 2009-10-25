	<% if config["include_toc"] %>
		\tocItem \markup { <%= config["movement"].to_movement_title %> }
	<% end %>
	<% if should_break(config) %>
	  \pageBreak
	<% end %>
	\score {
	  \new StaffGroup <<
		<% if (p = config["score/rendered_parts"]) && config["score/groups"] %>
			\set StaffGroup.systemStartDelimiterHierarchy = <%= staff_hierarchy(p, config) %>
		<% end %>
	  <% if (config["mode"] == :part) && (m = config["part_macro"]) %>
	    <%= m %>
	  <% elsif (config["mode"] == :score) && (m = config["score_macro"]) %>
	    <%= m %>
	  <% end %>
	<%= content %>
	  >>
	  <% if config["midi"] %>
	  \midi {
	    <% if midi_tempo = config["midi_tempo"] %>
	    \context {
	      \Score
	      tempoWholesPerMinute = #(ly:make-moment <%= midi_tempo %>)
	    }
	    <% end %>
	  }
	  <% end %>
	  \header { piece = \markup \bold \large "<%= config["movement"].to_movement_title %>" }
	  <% if (config["mode"] == :score) && (config["score/indent"]) %>
	  \layout {
      indent = <%= config["score/indent"] %>
    }
	  <% elsif (config["mode"] == :part) && (config["aux_staves"]) %>
	  \layout {
      indent = <%= config["score/indent"] || '2.7\cm' %>
    }
	  <% end %>
	}

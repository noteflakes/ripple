	<% if config["include_toc"] %>
		\tocItem \markup { <%= config["movement"].to_movement_title %> }
	<% end %>
	\score {
	  \new StaffGroup <<
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
	}

<% if should_break(config) %>
  }
  \bookpart {
    \pageBreak
    <% movement_blank_pages(config).times do %>
      \markup \column {
      \null \null \null \null \null \null
      \null \null \null \null \null \null
      \null \null \null \null \null \null
      \null \null \null \null \null \null
      \fill-line { "(this page has been left blank to facilitate page turning)" } 
  		}
      \pageBreak 
    <% end %>
<% end %>
	<% if config["include_toc"] %>
		\tocItem \markup { <%= movement_title(config) %> }
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
		<% if p = config["bar_number"] %>
		  \set Score.currentBarNumber = #<%= p %>
		  \set Score.barNumberVisibility = #all-bar-numbers-visible
		  \bar ""
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
	  \header { 
	    piece = \markup {
	      \column {
          \fill-line {\bold \large "<%= movement_title(config) %>"}
          <% if config["compiled"] %>
            \fill-line {\large "<%= (s = part_source(config)) && s.to_instrument_title %>"}
          <% end %>
	      }
	    }
	  }
	  <% if (config["mode"] == :score) && (config["score/indent"]) %>
	  \layout {
      indent = <%= config["score/indent"] %>
    }
	  <% elsif (config["mode"] == :part) && (config["aux_staves"]) %>
	  \layout {
      indent = <%= config["score/indent"] || '2.5\cm' %>
    }
	  <% end %>
	}

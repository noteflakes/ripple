\new Staff = <%= staff_name(config) %> \with {
  <% if show_ambitus(config) %>
    \consists "Ambitus_engraver"
  <% end %>
  <% if (smart_turns = smart_page_turns(config)) %>
    \consists "Page_turn_engraver"
  <% end %>
  <% if config["aux_staff"] %>
    fontSize = #-2
    \override StaffSymbol #'staff-space = #(magstep -2)
    \override StaffSymbol #'thickness = #(magstep -2)
  <% end %>
	<% if hidden_staff?(config) %>
	  \remove "Axis_group_engraver" 
  	\consists "Hara_kiri_engraver" 
  	\override Beam #'auto-knee-gap = #'() 
  	\override VerticalAxisGroup #'remove-empty = ##t  
	<% end %>
}

<% if figures = config["figures"] %>
  \figuremode {
    \set figuredBassAlterationDirection = #RIGHT
    \set figuredBassPlusDirection = #RIGHT
    <%= figures %>
  }
<% end %>

\context Staff = <%= staff_name(config) %> {
<% if name = config["staff_name"] %>\set Staff.instrumentName = #"<%= name %>"<% end %>
<% if inst = midi_instrument(config) %>\set Staff.midiInstrument = #"<%= inst %>"<% end %>
<% if clef = part_clef(config) %>\clef "<%= clef %>"<% end %>
<% if auto_beam_off(config) %>\autoBeamOff<% end %>
<% if smart_turns %>\set Staff.minimumPageTurnLength = #(ly:make-moment <%= smart_turns %>)<% end %>
%% <%= fn %>
<%= content %>
%%
<%= end_bar(config) %>
}

\new Staff \with {
  <% if show_ambitus(config) %>
    \consists "Ambitus_engraver"
  <% end %>
  <% if (smart_turns = smart_page_turns(config)) %>
    \consists "Page_turn_engraver"
  <% end %>
  <% if false && config["aux_staff"] %>
    fontSize = #-3
    \override StaffSymbol #'staff-space = #(magstep -3)
    \override StaffSymbol #'thickness = #(magstep -3)
  <% end %>
} {
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

\new Staff \with {
  <% if show_ambitus(config) %>
    \consists "Ambitus_engraver"
  <% end %>
  <% if config["aux_staff"] %>
    fontSize = #-3
    \override StaffSymbol #'staff-space = #(magstep -3)
    \override StaffSymbol #'thickness = #(magstep -3)
  <% end %>
} {
<% if name = config["staff_name"] %>\set Staff.instrumentName = #"<%= name %>"<% end %>
<% if inst = midi_instrument(config) %>\set Staff.midiInstrument = #"<%= inst %>"<% end %>
<% if clef = part_clef(config) %>\clef "<%= clef %>"<% end %>
<% if auto_beam_off(config) %>\autoBeamOff<% end %>
%% <%= fn %>
<%= content %>
%%
<%= end_bar(config) %>
}

\new Staff \with {
  <% if show_ambitus(data) %>
    \consists "Ambitus_engraver"
  <% end %>
  <% if data["aux_staff"] %>
    fontSize = #-3
    \override StaffSymbol #'staff-space = #(magstep -3)
    \override StaffSymbol #'thickness = #(magstep -3)
  <% end %>
} {
<% if name = data["staff_name"] %>\set Staff.instrumentName = #"<%= name %>"<% end %>
<% if inst = midi_instrument(data) %>\set Staff.midiInstrument = #"<%= inst %>"<% end %>
<% if clef = part_clef(data) %>\clef "<%= clef %>"<% end %>
<% if auto_beam_off(data) %>\autoBeamOff<% end %>
%% <%= fn %>
<%= content %>
%%
<%= end_bar(data) %>
}

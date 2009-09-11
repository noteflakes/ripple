\score {
  \new StaffGroup <<
  <% if (data["mode"] == :part) && (m = data["part_macro"]) %>
    <%= m %>
  <% elsif (data["mode"] == :score) && (m = data["score_macro"]) %>
    <%= m %>
  <% end %>
<%= content %>
  >>
  <% if data["midi"] %>
  \midi {
    <% if midi_tempo = data["midi_tempo"] %>
    \context {
      \Score
      tempoWholesPerMinute = #(ly:make-moment <%= midi_tempo %>)
    }
    <% end %>
  }
  <% end %>
  \header { piece = \markup \bold \large "<%= data["movement"].to_movement_title %>" }
}

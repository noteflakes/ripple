\addlyrics {
  \lyricmode {
    <% if data["aux_staff"] %>
      \override LyricText #'font-size = #-3
    <% end %>
    <%= content %>
  }
}

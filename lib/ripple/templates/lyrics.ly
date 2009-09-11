\addlyrics {
  \lyricmode {
    <% if config["aux_staff"] %>
      \override LyricText #'font-size = #-3
    <% end %>
    <%= content %>
  }
}

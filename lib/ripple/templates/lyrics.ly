\addlyrics {
  \lyricmode {
    <% if config["aux_staff"] %>
      \override LyricText #'font-size = #-2
    <% end %>
    <%= content %>
  }
}

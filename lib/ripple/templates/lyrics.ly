\addlyrics {
  \lyricmode {
    <% if false && config["aux_staff"] %>
      \override LyricText #'font-size = #-3
    <% end %>
    <%= content %>
  }
}

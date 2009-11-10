<% if should_break(config) %>
  }
  \bookpart {
    \pageBreak
<% end %>
\markup { \fill-line {\bold \large
    "<%= config["movement"].to_movement_title %> - tacet"
  }
}

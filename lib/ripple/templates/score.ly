<% include.each do |inc| %>\include "<%= inc %>"
<% end %>
\header {
  title = "<%= config["title"] %>"
  composer = "<%= config["composer"] %>"
}

<%= content %>

\version "2.12.2"


\new Staff {
  <% if clef = combined_part_clef(parts, config) %>\clef "<%= clef %>"<% end %>
  \set Staff.soloText = #""
  \set Staff.soloIIText = #""
  \set Staff.aDueText = #""
  \partcombine
<%= content %>
<%= end_bar(config) %>
}

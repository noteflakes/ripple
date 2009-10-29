\new Staff {
  <% if clef = part_clef(config.merge('part' => parts[0])) %>\clef "<%= clef %>"<% end %>
  \set Staff.soloText = #""
  \set Staff.soloIIText = #""
  \set Staff.aDueText = #""
  \partcombine
<%= content %>
<%= end_bar(config) %>
}

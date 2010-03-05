\new PianoStaff <<
  <% if name = config["staff_name"] %>\set PianoStaff.instrumentName = #"<%= name %>"<% end %>
  <%= content %>
>>

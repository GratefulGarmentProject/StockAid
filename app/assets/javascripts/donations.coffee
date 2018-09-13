#= require migrate_donations

$.guards.name("donorNameUnique").message("Donor name must be unique.").using (value) ->
  return true if value == ""
  names = ($(x).data("name") for x in $("#donor-selector option[data-name]"))
  !names.includes(value)

$.guards.name("donorEmailUnique").message("Donor email must be unique.").using (value) ->
  return true if value == ""
  emails = ($(x).data("email") for x in $("#donor-selector option[data-email]"))
  !emails.includes(value)

$(document).on "change", "#donor-selector", (event) ->
  option = $("option:selected", this)
  value = option.val()
  $("#existing-donor-fields, #new-donor-fields").empty()

  switch value
    when "" then # Do nothing
    when "new"
      content = tmpl("new-donor-template", {})
      $("#new-donor-fields").html(content).show()
    else
      content = tmpl("existing-donor-template", option.data())
      $("#existing-donor-fields").html(content).show()

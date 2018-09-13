$.guards.name("vendorNameUnique").message("Vendor name must be unique.").using (value) ->
  return true if value == ""
  names = ($(x).data("name") for x in $("#vendor-selector option[data-name]"))
  !names.includes(value)

$.guards.name("vendorEmailUnique").message("Vendor email must be unique.").using (value) ->
  return true if value == ""
  emails = ($(x).data("email") for x in $("#vendor-selector option[data-email]"))
  !emails.includes(value)

$(document).on "change", "#vendor-selector", (event) ->
  option = $("option:selected", this)
  value = option.val()
  $("#existing-vendor-fields, #new-vendor-fields").empty()

  switch value
    when "" then # Do nothing
    when "new"
      content = tmpl("new-vendor-template", {})
      $("#new-vendor-fields").html(content).show()
    else
      content = tmpl("existing-vendor-template", option.data())
      $("#existing-vendor-fields").html(content).show()

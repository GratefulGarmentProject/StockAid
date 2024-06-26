require("./migrate_donations")

$.guards.name("donorNameUnique").message("Donor name must be unique.").using (value) ->
  return true if value == ""
  names = ($(x).data("name") for x in $("#donor-selector option[data-name]"))
  !names.includes(value)

$.guards.name("donorEmailUnique").message("Donor email must be unique.").using (value) ->
  return true if value == ""
  emails = ($(x).data("email") for x in $("#donor-selector option[data-email]"))
  !emails.includes(value)

$.guards.name("donorExternalIdUnique").message("Donor external id must be unique.").using (value) ->
  return true if value == ""
  externalIds = ($(x).data("external-id") for x in $("#donor-selector option[data-external-id]"))
  !externalIds.includes(value)

$(document).on "change", "#donor-selector", (event) ->
  option = $("option:selected", this)
  value = option.val()
  $("#existing-donor-fields, #new-donor-fields").empty()

  switch value
    when "" then # Do nothing
    when "new"
      content = tmpl("new-donor-template", {})
      $("#new-donor-fields").html(content).show()
      initializeExternalTypeSelector()
    else
      content = tmpl("existing-donor-template", option.data())
      $("#existing-donor-fields").html(content).show()

expose "initializeDonors", ->
  defaultMatcher = $.fn.select2.defaults.defaults.matcher

  $ ->
    $("#donor-selector, .donor-selector").select2
      theme: "bootstrap"
      width: "100%"
      matcher: (params, data) ->
        textToMatch = data.element.getAttribute("data-search-text") || ""

        if defaultMatcher(params, { text: textToMatch })
          data
        else
          null

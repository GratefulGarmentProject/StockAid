#= require migrate_donations

$.guards.name("donorUnique").message("Donor name must be unique.").using (value) ->
  return true if value == ""
  donors = ($(x).data("name") for x in $("#donor-selector option[data-name]"))
  !donors.includes(value)

addDonationRow = ->
  row = $ tmpl("donation-row-template", {})
  $("#donation-table tbody").append row
  row.find("select").select2(theme: "bootstrap", width: "100%")

expose "addInitialDonationRow", ->
  $ ->
    addDonationRow()

$(document).on "click", "#add-donation-row", (event) ->
  event.preventDefault()
  addDonationRow()

$(document).on "click", ".delete-donation-row", (event) ->
  event.preventDefault()
  $(@).parents("tr:first").remove()
  addDonationRow() if $("#donation-table tbody tr").length == 0

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

expose "initializeDonors", ->
  defaultMatcher = $.fn.select2.defaults.defaults.matcher

  $ ->
    $("#donor-selector").select2
      theme: "bootstrap"
      width: "100%"
      matcher: (params, data) ->
        textToMatch = data.element.getAttribute("data-search-text") || ""

        if defaultMatcher(params, { text: textToMatch })
          data
        else
          null

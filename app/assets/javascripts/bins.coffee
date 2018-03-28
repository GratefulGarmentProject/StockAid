$.guards.name("binLocationUnique").grouped().target("#bin-location-error-target").message("Location must be unique.").using (values) ->
  rack = values[0]
  shelf = values[1]
  return true if rack == "" && shelf == ""

  for x in $("#bin-location-selector option[data-rack][data-shelf]")
    xRack = $(x).data("rack")
    xShelf = $(x).data("shelf")
    return false if rack == xRack && shelf == xShelf

  true

$(document).on "change", "#bin-location-selector", (event) ->
  option = $("option:selected", this)
  value = option.val()
  $("#existing-bin-location-fields, #new-bin-location-fields").empty()

  switch value
    when "" then # Do nothing
    when "new"
      content = tmpl("new-bin-location-template", {})
      $("#new-bin-location-fields").html(content).show()
    else
      content = tmpl("existing-bin-location-template", option.data())
      $("#existing-bin-location-fields").html(content).show()

expose "initializeBinLocations", ->
  defaultMatcher = $.fn.select2.defaults.defaults.matcher

  $ ->
    $("#bin-location-selector").select2
      theme: "bootstrap"
      width: "100%"
      matcher: (params, data) ->
        textToMatch = data.element.getAttribute("data-search-text") || ""

        if defaultMatcher(params, { text: textToMatch })
          data
        else
          null

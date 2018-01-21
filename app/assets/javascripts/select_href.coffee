$(document).on "change", "select.select-href", (ev) ->
  option = $(@).find("option:selected")

  if option.data("href")
    window.location = option.data("href")

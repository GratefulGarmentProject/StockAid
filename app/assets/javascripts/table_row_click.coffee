$(document).on "click", "tr[data-href]", (ev) ->
  element = $(ev.target)
  row = $(ev.currentTarget)

  return if element.parents("a, button").length > 0
  return if $.inArray(element.prop("tagName").toLowerCase(), ["select", "a", "button"]) != -1
  window.location = row.data("href") if row.data("href")?

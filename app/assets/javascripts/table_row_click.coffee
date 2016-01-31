$(document).on "click", "tr[data-click-fn], tr[data-href]", (ev) ->
  element = $(ev.target)
  row = $(ev.currentTarget)

  return if element.parents("a, button").length > 0
  return if $.inArray(element.prop("tagName").toLowerCase(), ["select", "a", "button"]) != -1

  if row.is("tr[data-href]") && row.data("href")?
    window.location = row.data("href")
  else if row.is("tr[data-click-fn]") && row.data("click-fn")?
    window[row.data("click-fn")](ev, row, element)

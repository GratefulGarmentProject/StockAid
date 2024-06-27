$.guards.name("countsheetitemdupes").message("You have duplicate items selected.").using (value) ->
  values = []

  $(".item-selector").each ->
    values.push $(@).val()

  $("tr[data-count-sheet-detail-item-id]").each ->
    # The other types are string, so make sure this is a string
    values.push "#{$(@).data("count-sheet-detail-item-id")}"

  count = 0

  for x in values
    count += 1 if x == value

  count <= 1

$(document).on "click", ".fill-final-count", (e) ->
  e.preventDefault()

  $(@).parents("table:first").find("tbody .final-count").each ->
    input = $(@)
    return if $.guards.isPresent(input.val())
    counts = {}

    input.parents("tr:first").find(".count").each ->
      countInput = $(@)
      countValue = countInput.val()
      return if $.guards.isBlank(countValue)
      counts[countValue] = counts[countValue] || 0
      counts[countValue] += 1

    countsArray = []
    $.each counts, (count, amount) -> countsArray.push([count, amount])
    return if countsArray.length == 0
    countsArray.sort (a, b) -> b[1] - a[1]

    # If there is 1 element, then all the counts agree, so just fill it in
    if countsArray.length == 1
      input.val(countsArray[0][0])
      return

    # If the first and second values are the same, that means we have a
    # tie... so don't fill it in (ties need to be handled manually)
    return if countsArray[0][1] == countsArray[1][1]

    # There is more than 1 count, but the first is a winner, so use that value
    input.val(countsArray[0][0])

$(document).on "click", ".add-counter-column", (e) ->
  e.preventDefault()
  columnNumber = $(@).parents("thead tr:first").find(".counter-column").length + 1
  $(@).parents("th:first").before tmpl("count-sheet-new-column-header-template", columnNumber: columnNumber)

  $(@).parents("table:first").find("tbody td.empty-column").before ->
    row = $(@).parents("tr:first")

    if row.is("[data-count-sheet-new-item]")
      rowId = row.data("count-sheet-row-id")
      tmpl("count-sheet-new-column-new-item-template", rowId: rowId, columnNumber: columnNumber)
    else
      detailId = row.data("count-sheet-detail-id")
      tmpl("count-sheet-new-column-existing-item-template", detailId: detailId, columnNumber: columnNumber)

expose "onCountSheetRowClick", (ev, row, element) ->
  api = new $.fn.dataTable.Api("table")
  path = row.data("path")
  path += "?page=#{api.page()}"
  window.location = path

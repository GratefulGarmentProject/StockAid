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
  columnNumber = $(@).parents("thead tr:first").find(".counter-column").size() + 1

  $(@).parents("th:first").before """
    <th class="counter-column form-group">
      <input type="text" class="form-control" name="counter_names[]" placeholder="Counter Name" data-guard="allOrNone" data-guard-all-or-none-group="allornone-#{columnNumber}" />
    </th>
  """
  $(@).parents("table:first").find("tbody td.empty-column").before ->
    row = $(@).parents("tr:first")

    if row.is("[data-count-sheet-new-item]")
      rowId = row.data("count-sheet-row-id")

      """
        <td class="form-group">
          <input type="text" class="form-control count" name="new_count_sheet_items[#{rowId}][counts][]" placeholder="Count" data-guard="int allOrNone" data-guard-int-min="0" data-guard-all-or-none-group="allornone-#{columnNumber}" />
        </td>
      """
    else
      detailId = row.data("count-sheet-detail-id")

      """
        <td class="form-group">
          <input type="text" class="form-control count" name="counts[#{detailId}][]" placeholder="Count" data-guard="int allOrNone" data-guard-int-min="0" data-guard-all-or-none-group="allornone-#{columnNumber}" />
        </td>
      """

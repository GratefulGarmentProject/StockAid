$(document).on "click", ".add-counter-column", (e) ->
    e.preventDefault()
    columnNumber = $(@).parents("thead tr:first").find(".counter-column").size() + 1

    $(@).parents("th:first").before """
      <th class="counter-column form-group">
        <input type="text" class="form-control" name="counter_names[]" placeholder="Counter Name" data-guard="allOrNone" data-guard-all-or-none-group="allornone-#{columnNumber}" />
      </th>
    """
    $(@).parents("table:first").find("tbody td.empty-column").before ->
      detailId = $(@).parents("tr:first").data("count-sheet-detail-id")

      """
        <td class="form-group">
          <input type="text" class="form-control" name="counts[#{detailId}][]" placeholder="Count" data-guard="allOrNone" data-guard-all-or-none-group="allornone-#{columnNumber}" />
        </td>
      """

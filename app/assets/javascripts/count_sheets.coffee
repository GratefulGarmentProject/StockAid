$(document).on "click", ".add-counter-column", (e) ->
    e.preventDefault()
    $(@).parents("th:first").before """
      <th>
        <input type="text" class="form-control" name="counter_names[]" placeholder="Counter Name" />
      </th>
    """
    $(@).parents("table:first").find("tbody td.empty-column").before ->
      detailId = $(@).parents("tr:first").data("count-sheet-detail-id")

      """
        <td>
          <input type="text" class="form-control" name="counts[#{detailId}][]" placeholder="Count" />
        </td>
      """

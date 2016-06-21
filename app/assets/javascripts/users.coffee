removeOrgRows = ($table) ->
  $table.find("tbody tr.additional-organization-row").remove()

rezebra = ($table) ->
  $table.find("tbody tr:visible:even").removeClass("odd-row even-row").addClass("odd-row")
  $table.find("tbody tr:visible:odd").removeClass("odd-row even-row").addClass("even-row")

addOrgRows = ($table) ->
  $table.find("tbody tr:visible[data-has-additional-organizations]").each ->
    $row = $(@)
    $rows = $()

    if $row.is(".odd-row")
      rowClass = "odd-row"
    else
      rowClass = "even-row"

    for organization in $row.data("additionalOrganizations")
      row = """
        <tr class="additional-organization-row #{rowClass}">
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td><a></a></td>
          <td></td>
        </tr>"""
      $newRow = $(row)
      $newRow.find("td:eq(4) a").text(organization.name).attr("href", organization.href)
      $newRow.find("td:eq(5)").text(organization.role)
      $newRow.attr("data-href", $row.attr("data-href"))
      $rows = $rows.add($newRow)

    $row.after($rows)

$(document).on "draw.dt search.dt order.dt", ".users-table.data-table", ->
  $table = $(@)
  removeOrgRows $table
  rezebra $table
  addOrgRows $table

$(document).on "page:change", ->
  $.guard("#user-password, #user-password-confirmation").using("regex", /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[a-zA-Z0-9]{8,72}$/)

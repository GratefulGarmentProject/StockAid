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
      row = tmpl "users-additional-organization-row-template",
        rowClass: rowClass
        organization: organization
      $newRow = $(row)
      $rows = $rows.add($newRow)

    $row.after($rows)

$(document).on "draw.dt search.dt order.dt", ".users-table.data-table", ->
  $table = $(@)
  removeOrgRows $table
  rezebra $table
  addOrgRows $table

$(document).on "page:change", ->
  $(".data-table").each ->
    table = $(@)
    return if $.fn.dataTable.isDataTable(table)
    if table.hasClass("sort-asc")
      table.DataTable
        responsive: true
    else
      table.DataTable
        responsive: true
        order: [[ 0, "desc" ]]

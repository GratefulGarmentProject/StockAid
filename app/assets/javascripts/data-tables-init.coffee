$(document).on "page:change", ->
  $(".data-table").each ->
    table = $(@)
    return if $.fn.dataTable.isDataTable(table)
    table.DataTable
      responsive: true
      order: [[ 0, "desc" ]]

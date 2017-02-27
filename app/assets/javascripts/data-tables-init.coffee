$(document).on "page:change", ->
  $(".data-table").each ->
    table = $(@)

    return if $.fn.dataTable.isDataTable(table)

    options =
      responsive: true

    unless table.hasClass("sort-asc")
      options["order"] = [[ 0, "desc" ]]

    if table.hasClass("no-pagination")
      options["paging"] = false

    table.dataTable(options)

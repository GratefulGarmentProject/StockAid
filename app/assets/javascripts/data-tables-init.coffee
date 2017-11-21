$(document).on "page:change", ->
  $(".data-table").each ->
    table = $(@)

    return if $.fn.dataTable.isDataTable(table)

    options =
      responsive: true
      order: [[0, "desc"]]
      pageLength: 25

    ascColumn = table.find("th.sort-asc").index()
    descColumn = table.find("th.sort-desc").index()

    if (ascColumn >= 0)
      options["order"] = [[ ascColumn, "asc" ]]

    if (descColumn >= 0)
      options["order"] = [[ descColumn, "desc" ]]

    if table.hasClass("no-paging")
      options["paging"] = false

    table.dataTable(options)

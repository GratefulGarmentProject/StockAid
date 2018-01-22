$(document).on "page:change", ->
  $(".data-table").each ->
    table = $(@)

    return if $.fn.dataTable.isDataTable(table)

    fnFooterCallback = (row, data, start, end, display) ->
      monetaryColumnIndex = 1

      # Utility function to convert string dollar amount to a number
      intVal = (i) ->
        if typeof i == 'string' then i.replace(/[\$,]/g, '') * 1 else if typeof i == 'number' then i else 0

      # Calculate the total for the current page
      pageTotal = @api().column(monetaryColumnIndex, page: 'current').data().reduce(((a, b) ->
        intVal(a) + intVal(b)
      ), 0).toFixed(2)

      # Render the pageTotal on the bottom footer.
      $(@api().column(monetaryColumnIndex).footer()).html '$'+ pageTotal 

    options =
      responsive: true
      order: [[0, "desc"]]
      pageLength: 25
      fnFooterCallback: fnFooterCallback

    ascColumn = table.find("th.sort-asc").index()
    descColumn = table.find("th.sort-desc").index()

    if (ascColumn >= 0)
      options["order"] = [[ ascColumn, "asc" ]]

    if (descColumn >= 0)
      options["order"] = [[ descColumn, "desc" ]]

    if table.hasClass("no-paging")
      options["paging"] = false

    table.dataTable(options)

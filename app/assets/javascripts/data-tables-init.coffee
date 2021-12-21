$(document).on "page:change", ->
  $(".data-table").each ->
    table = $(@)

    return if $.fn.dataTable.isDataTable(table)


    fnFooterCallback = (row, data, start, end, display) ->
      numColumnIndex = table.find("th.num-value").index()
      monetaryColumnIndex1 = table.find("th.monetary-value-1").index()
      monetaryColumnIndex2 = table.find("th.monetary-value-2").index()

      # Utility function to convert "1234567.00" to "1,234,567.00"
      numberWithCommas = (x) ->
        x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
      # Utility function to convert string dollar amount to a number
      intVal = (i) ->
        if typeof i == 'string' then i.replace(/[\$,]/g, '') * 1 else if typeof i == 'number' then i else 0

      # Calculate the number totals for the current page
      numTotal = @api().column(numColumnIndex, page: 'current').data().reduce(((a, b) ->
        intVal(a) + intVal(b)
      ), 0)
      $(@api().column(numColumnIndex).footer()).html numTotal


      # Calculate the number totals for the current page
      if monetaryColumnIndex1 > -1
        pageTotal = @api().column(monetaryColumnIndex1, page: 'current').data().reduce(((a, b) ->
          intVal(a) + intVal(b)
        ), 0).toFixed(2)
        $(@api().column(monetaryColumnIndex1).footer()).html '$'+ numberWithCommas(pageTotal)

      if monetaryColumnIndex2 > -1
        pageTotal = @api().column(monetaryColumnIndex2, page: 'current').data().reduce(((a, b) ->
          intVal(a) + intVal(b)
        ), 0).toFixed(2)
        $(@api().column(monetaryColumnIndex2).footer()).html '$'+ numberWithCommas(pageTotal)

      # Render the totals on the footer

    fnRowCallback = (row, data, index) ->
      $row = $(row)

      if $row.is("[data-toggle='tooltip']")
        $row.tooltip()

    options =
      responsive: true
      order: [[0, "desc"]]
      lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
      pageLength: 25
      fnFooterCallback: fnFooterCallback
      fnRowCallback: fnRowCallback

    ascColumn = table.find("th.sort-asc").index()
    descColumn = table.find("th.sort-desc").index()

    if (ascColumn >= 0)
      options["order"] = [[ ascColumn, "asc" ]]

    if (descColumn >= 0)
      options["order"] = [[ descColumn, "desc" ]]

    if table.hasClass("no-paging")
      options["paging"] = false

    if table.hasClass("preserve-default-order")
      options["order"] = []

    table.dataTable(options)

    if table.hasClass("autofocus-search")
        $("div.dataTables_filter input").focus()

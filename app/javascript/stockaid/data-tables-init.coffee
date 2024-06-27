$(document).on "length.dt", (e, settings, length) ->
  $.cookies.create("datatable-default-length", length)

# Utility function to convert string dollar amount to a number
intVal = (i) ->
  if typeof i == "string"
    i.replace(/[\$,]/g, "") * 1
  else if typeof i == "number"
    i
  else
    0

# Utility function to convert "1234567.00" to "1,234,567.00"
numberWithCommas = (x) ->
  x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

summarizeNumValue = (api, index) ->
  total = api.column(index, page: "current").data().reduce(((a, b) ->
    intVal(a) + intVal(b)
  ), 0)

  $(api.column(index).footer()).html "#{total}"

summarizeMonetaryValue = (api, index) ->
  total = api.column(index, page: "current").data().reduce(((a, b) ->
    intVal(a) + intVal(b)
  ), 0).toFixed(2)

  $(api.column(index).footer()).html "$#{numberWithCommas(total)}"

$(document).on "turbolinks:load", ->
  $(".data-table").each ->
    table = $(@)

    return if $.fn.dataTable.isDataTable(table)

    fnFooterCallback = (row, data, start, end, display) ->
      api = @api()

      table.find("th.num-value").each ->
        header = $(@)
        return if header.is(".no-total")
        summarizeNumValue(api, header.index())

      table.find("th.monetary-value").each ->
        header = $(@)
        return if header.is(".no-total")
        summarizeMonetaryValue(api, header.index())

    fnRowCallback = (row, data, index) ->
      $row = $(row)

      if $row.is("[data-toggle='tooltip']")
        $row.tooltip()

    options =
      responsive: true
      order: [[0, "desc"]]
      lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
      pageLength: $.cookies.readInt("datatable-default-length", -1)
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

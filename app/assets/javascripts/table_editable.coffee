class TableEditable
  constructor: (@tableId, @_table) ->

  initialize: (numRows, callback) ->
    $ =>
      rows = (@add() for i in [0...numRows])
      callback(rows) if callback

  table: ->
    @_table = $("##{@tableId}") unless @_table
    @_table

  add: ->
    row = $ tmpl(@table().data("table-editable-row-template-id"), {})
    @table().find("tbody").append row
    row.find("select").select2(theme: "bootstrap", width: "100%")
    row

  autoAddRow: ->
    return unless @table().find("tbody tr").length == 0
    return if @table().is("[data-table-editable-allow-no-rows]")
    @add()

  delete: (source) ->
    $(source).parents("tr:first").remove()
    @autoAddRow()

$.tableEditable = (tableId, table) ->
  new TableEditable(tableId, table)

$(document).on "click", ".table-editable-add", (event) ->
  event.preventDefault()
  $.tableEditable($(this).data("table-editable-for")).add()

$(document).on "click", ".table-editable tr .table-editable-delete", (event) ->
  event.preventDefault()
  $.tableEditable(null, $(this).parents(".table-editable:first")).delete(this)

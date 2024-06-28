/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
class TableEditable {
  constructor(tableId, _table) {
    this.tableId = tableId;
    this._table = _table;
  }

  initialize(numRows, callback) {
    return $(() => {
      const rows = (__range__(0, numRows, false).map((i) => this.add()));
      if (callback) { return callback(rows); }
    });
  }

  table() {
    if (!this._table) { this._table = $(`#${this.tableId}`); }
    return this._table;
  }

  add() {
    const row = $(tmpl(this.table().data("table-editable-row-template-id"), { tableId: this.tableId }));
    this.table().find("tbody").append(row);
    row.find("select").select2({theme: "bootstrap", width: "100%"});
    return row;
  }

  autoAddRow() {
    if (this.table().find("tbody tr").length !== 0) { return; }
    if (this.table().is("[data-table-editable-allow-no-rows]")) { return; }
    return this.add();
  }

  delete(source) {
    $(source).parents("tr:first").remove();
    return this.autoAddRow();
  }
}

$.tableEditable = (tableId, table) => new TableEditable(tableId, table);

$(document).on("click", ".table-editable-add", function(event) {
  event.preventDefault();
  return $.tableEditable($(this).data("table-editable-for")).add();
});

$(document).on("click", ".table-editable tr .table-editable-delete", function(event) {
  event.preventDefault();
  return $.tableEditable(null, $(this).parents(".table-editable:first")).delete(this);
});

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}
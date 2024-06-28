/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$(document).on("length.dt", (e, settings, length) => $.cookies.create("datatable-default-length", length));

// Utility function to convert string dollar amount to a number
const intVal = function(i) {
  if (typeof i === "string") {
    return i.replace(/[\$,]/g, "") * 1;
  } else if (typeof i === "number") {
    return i;
  } else {
    return 0;
  }
};

// Utility function to convert "1234567.00" to "1,234,567.00"
const numberWithCommas = x => x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");

const summarizeNumValue = function(api, index) {
  const total = api.column(index, {page: "current"}).data().reduce(((a, b) => intVal(a) + intVal(b)), 0);

  return $(api.column(index).footer()).html(`${total}`);
};

const summarizeMonetaryValue = function(api, index) {
  const total = api.column(index, {page: "current"}).data().reduce(((a, b) => intVal(a) + intVal(b)), 0).toFixed(2);

  return $(api.column(index).footer()).html(`$${numberWithCommas(total)}`);
};

$(document).on("turbolinks:load", () => $(".data-table").each(function() {
  const table = $(this);

  if ($.fn.dataTable.isDataTable(table)) { return; }

  const fnFooterCallback = function(row, data, start, end, display) {
    const api = this.api();

    table.find("th.num-value").each(function() {
      const header = $(this);
      if (header.is(".no-total")) { return; }
      return summarizeNumValue(api, header.index());
    });

    return table.find("th.monetary-value").each(function() {
      const header = $(this);
      if (header.is(".no-total")) { return; }
      return summarizeMonetaryValue(api, header.index());
    });
  };

  const fnRowCallback = function(row, data, index) {
    const $row = $(row);

    if ($row.is("[data-toggle='tooltip']")) {
      return $row.tooltip();
    }
  };

  const options = {
    responsive: true,
    order: [[0, "desc"]],
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    pageLength: $.cookies.readInt("datatable-default-length", -1),
    fnFooterCallback,
    fnRowCallback
  };

  const ascColumn = table.find("th.sort-asc").index();
  const descColumn = table.find("th.sort-desc").index();

  if (ascColumn >= 0) {
    options["order"] = [[ ascColumn, "asc" ]];
  }

  if (descColumn >= 0) {
    options["order"] = [[ descColumn, "desc" ]];
  }

  if (table.hasClass("no-paging")) {
    options["paging"] = false;
  }

  if (table.hasClass("preserve-default-order")) {
    options["order"] = [];
  }

  table.dataTable(options);

  if (table.hasClass("autofocus-search")) {
      return $("div.dataTables_filter input").focus();
    }
}));

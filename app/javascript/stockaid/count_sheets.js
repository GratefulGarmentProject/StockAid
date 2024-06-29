/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$.guards.name("countsheetitemdupes").message("You have duplicate items selected.").using(function(value) {
  const values = [];

  $(".item-selector").each(function() {
    return values.push($(this).val());
  });

  $("tr[data-count-sheet-detail-item-id]").each(function() {
    // The other types are string, so make sure this is a string
    return values.push(`${$(this).data("count-sheet-detail-item-id")}`);
  });

  let count = 0;

  for (var x of Array.from(values)) {
    if (x === value) { count += 1; }
  }

  return count <= 1;
});

$(document).on("click", ".fill-final-count", function(e) {
  e.preventDefault();

  return $(this).parents("table:first").find("tbody .final-count").each(function() {
    const input = $(this);
    if ($.guards.isPresent(input.val())) { return; }
    const counts = {};

    input.parents("tr:first").find(".count").each(function() {
      const countInput = $(this);
      const countValue = countInput.val();
      if ($.guards.isBlank(countValue)) { return; }
      counts[countValue] = counts[countValue] || 0;
      return counts[countValue] += 1;
    });

    const countsArray = [];
    $.each(counts, (count, amount) => countsArray.push([count, amount]));
    if (countsArray.length === 0) { return; }
    countsArray.sort((a, b) => b[1] - a[1]);

    // If there is 1 element, then all the counts agree, so just fill it in
    if (countsArray.length === 1) {
      input.val(countsArray[0][0]);
      return;
    }

    // If the first and second values are the same, that means we have a
    // tie... so don't fill it in (ties need to be handled manually)
    if (countsArray[0][1] === countsArray[1][1]) { return; }

    // There is more than 1 count, but the first is a winner, so use that value
    return input.val(countsArray[0][0]);
  });
});

$(document).on("click", ".add-counter-column", function(e) {
  e.preventDefault();
  const columnNumber = $(this).parents("thead tr:first").find(".counter-column").length + 1;
  $(this).parents("th:first").before(tmpl("count-sheet-new-column-header-template", {columnNumber}));

  return $(this).parents("table:first").find("tbody td.empty-column").before(function() {
    const row = $(this).parents("tr:first");

    if (row.is("[data-count-sheet-new-item]")) {
      const rowId = row.data("count-sheet-row-id");
      return tmpl("count-sheet-new-column-new-item-template", {rowId, columnNumber});
    } else {
      const detailId = row.data("count-sheet-detail-id");
      return tmpl("count-sheet-new-column-existing-item-template", {detailId, columnNumber});
    }
  });
});

expose("onCountSheetRowClick", function(ev, row, element) {
  const api = new $.fn.dataTable.Api("table");
  let path = row.data("path");
  path += `?page=${api.page()}`;
  return window.location = path;
});

$(document).on("turbolinks:load", () => {
  if ($("#count-sheet-row-template").length > 0) {
    $.tableEditable("count-sheet-table").initialize(0);
  }
});

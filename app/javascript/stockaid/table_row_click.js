/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$(document).on("click", "tr[data-click-fn], tr[data-href]", function(ev) {
  const element = $(ev.target);
  const row = $(ev.currentTarget);

  if (element.parents("a, button").length > 0) { return; }
  if ($.inArray(element.prop("tagName").toLowerCase(), ["select", "a", "button"]) !== -1) { return; }

  if (row.is("tr[data-href]") && (row.data("href") != null)) {
    return window.location = row.data("href");
  } else if (row.is("tr[data-click-fn]") && (row.data("click-fn") != null)) {
    return window[row.data("click-fn")](ev, row, element);
  }
});

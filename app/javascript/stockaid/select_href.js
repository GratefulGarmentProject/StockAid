/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$(document).on("change", "select.select-href", function(ev) {
  const option = $(this).find("option:selected");

  if (option.data("href")) {
    return window.location = option.data("href");
  }
});

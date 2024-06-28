/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$(document).on("click", ".check-all", function(e) {
  e.preventDefault();
  e.stopPropagation();

  const selector = $(this).data("check-all-target");
  return $(selector).find(":checkbox").prop("checked", true).change();
});

$(document).on("click", ".uncheck-all", function(e) {
  e.preventDefault();
  e.stopPropagation();

  const selector = $(this).data("uncheck-all-target");
  return $(selector).find(":checkbox").prop("checked", false).change();
});

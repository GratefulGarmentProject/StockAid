/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$(document).on("click", ".js-select-all", ev => $("input:checkbox").prop("checked", true));

$(document).on("click", ".js-select-none", ev => $("input:checkbox").prop("checked", false));

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$(document).on("turbolinks:load", () => $("select.program").select2({ theme: "bootstrap", width: "100%" }));

$(document).on("turbolinks:load", () => $("select.program-survey").select2({ theme: "bootstrap", width: "100%" }));

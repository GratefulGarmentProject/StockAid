/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
require("./migrate_donations");

$.guards.name("donorNameUnique").message("Donor name must be unique.").using(function(value) {
  if (value === "") { return true; }
  const names = (Array.from($("#donor-selector option[data-name]")).map((x) => $(x).data("name")));
  return !names.includes(value);
});

$.guards.name("donorEmailUnique").message("Donor email must be unique.").using(function(value) {
  if (value === "") { return true; }
  const emails = (Array.from($("#donor-selector option[data-email]")).map((x) => $(x).data("email")));
  return !emails.includes(value);
});

$.guards.name("donorExternalIdUnique").message("Donor external id must be unique.").using(function(value) {
  if (value === "") { return true; }
  const externalIds = (Array.from($("#donor-selector option[data-external-id]")).map((x) => $(x).data("external-id")));
  return !externalIds.includes(value);
});

$(document).on("change", "#donor-selector", function(event) {
  const option = $("option:selected", this);
  const value = option.val();
  $("#existing-donor-fields, #new-donor-fields").empty();

  switch (value) {
    case "": // Do nothing
    case "new":
      var content = tmpl("new-donor-template", {});
      $("#new-donor-fields").html(content).show();

      $("#external-type").select2({
        placeholder: "Select a type",
        theme: "bootstrap",
        width: "100%"
      });

      return;
    default:
      content = tmpl("existing-donor-template", option.data());
      return $("#existing-donor-fields").html(content).show();
  }
});

expose("initializeDonors", function() {
  const defaultMatcher = $.fn.select2.defaults.defaults.matcher;

  return $(() => $("#donor-selector, .donor-selector").select2({
    theme: "bootstrap",
    width: "100%",
    matcher(params, data) {
      const textToMatch = data.element.getAttribute("data-search-text") || "";

      if (defaultMatcher(params, { text: textToMatch })) {
        return data;
      } else {
        return null;
      }
    }
  }));
});

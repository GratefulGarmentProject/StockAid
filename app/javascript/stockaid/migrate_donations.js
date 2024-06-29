/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const fillFields = function(row) {
  let match;
  const originalNotes = row.find(".donation-original-notes").text();

  const notesField = row.find("input[name='donations[notes][]']");
  notesField.val(row.find(".donation-notes-field").data("value") || "");

  const dateField = row.find("input[name='donations[date][]']");
  let dateValue = row.find(".donation-date-field").data("value");

  if (!dateValue) {
    match = /\b(\d+)\/(\d+)\/(\d+)\b/.exec(originalNotes);

    const pad = function(x) {
      if (x.length < 2) {
        return `0${x}`;
      } else {
        return x;
      }
    };

    if (match) {
      dateValue = `20${match[3]}-${pad(match[1])}-${pad(match[2])}`;
    } else {
      dateValue = row.find(".donation-date").text();
    }
  }

  dateField.val(dateValue);

  const depadDecomma = function(x) {
    const spacingMatch = /^\s*(.*?)(?:\s|,)*$/.exec(x);

    if (spacingMatch) {
      return spacingMatch[1];
    } else {
      return x;
    }
  };

  const donorSelector = $("#donor-selector");
  let name = originalNotes.replace(/\s+(\d+)\/(\d+)\/(\d+)\b/, "");
  let address = "";
  let email = "";
  let notes = "";
  match = /Donation from: (.*?)(?:\s+address: (.*?))?(?:\s+email: (.*?))?(?:\s+notes: (.*?))?$/.exec(name);
  if (match) { name = depadDecomma(match[1]); }
  if (match && match[2]) { address = depadDecomma(match[2]); }
  if (match && match[3]) { email = depadDecomma(match[3]); }
  if (match && match[4]) { notes = depadDecomma(match[4]); }

  if (donorSelector.val() === "") {
    donorSelector.val("new").trigger("change");
    $("#donor-name").val(name);
    $("#donor-address").val(address);
    $("#donor-email").val(email);
  }

  if (notesField.val() === "") {
    return notesField.val(notes);
  }
};

$(document).on("change", ".migrate-donation-checkbox", function() {
  const checkbox = $(this);
  const row = checkbox.parents("tr:first");

  if (checkbox.is(":checked")) {
    row.find(".donation-notes-field").append("<input type=\"text\" name=\"donations[notes][]\" class=\"form-control\" />");
    row.find(".donation-date").hide();
    row.find(".donation-date-field").append("<input type=\"text\" name=\"donations[date][]\" class=\"form-control\" data-provide=\"datepicker\" data-date-format=\"yyyy-mm-dd\" />");
    return fillFields(row);
  } else {
    row.find(".donation-notes-field").data("value", row.find(".donation-notes-field input").val()).empty();
    row.find(".donation-date").show();
    return row.find(".donation-date-field").data("value", row.find(".donation-date-field input").val()).empty();
  }
});

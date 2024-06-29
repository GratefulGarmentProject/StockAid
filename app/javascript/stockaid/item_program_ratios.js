/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$.guards.name("programsAddTo100").grouped().target("#100-percent-error-target").message("Program percentages must add to 100%").using(function(values) {
  let sum = 0.0;

  for (var value of Array.from(values)) {
    sum += parseFloat(value);
  }

  if (sum < 99.9999) { return false; }
  if (sum > 100.0001) { return false; }
  return true;
});

$(document).on("change", ":checkbox.apply-to-items-checkbox", function(e) {
  const parent = $(this).parents(".apply-to-items-checkbox-parent:first");
  const label = parent.find(".amount-apply-to-items-checked");
  const amount = parent.find(":checkbox.apply-to-items-checkbox:checked").length;
  label.text(`(${amount} checked)`);

  if (amount > 0) {
    return label.addClass("text-bold");
  } else {
    return label.removeClass("text-bold");
  }
});

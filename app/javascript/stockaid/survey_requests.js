/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$(document).on("change", ":checkbox.selected-survey-request-organization-checkbox", function(e) {
  const label = $(".amount-survey-request-organizations-checked");
  const amount = $(":checkbox.selected-survey-request-organization-checkbox:checked").length;
  label.text(`(${amount} checked)`);

  if (amount > 0) {
    return label.addClass("text-bold");
  } else {
    return label.removeClass("text-bold");
  }
});

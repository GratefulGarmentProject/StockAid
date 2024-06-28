/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
expose("addAddressRow", () => $("#organization_info").append(tmpl("organizations-new-address-template", {})));

$(document).on("click", "#add-new-address", function(event) {
  event.preventDefault();
  return addAddressRow();
});

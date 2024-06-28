const addAddressRow = function() {
  $("#organization_info").append(tmpl("organizations-new-address-template", {}));
};

$(document).on("click", "#add-new-address", function(event) {
  event.preventDefault();
  addAddressRow();
});

$(document).on("turbolinks:load", () => {
  if ($("#organization_info.add-initial-address").length > 0) {
    addAddressRow();
  }
});

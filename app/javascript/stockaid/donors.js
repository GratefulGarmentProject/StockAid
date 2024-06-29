var externalIdGuard = $.guard("#donor_external_id").using("never").message("This is required when not exporting.")

$(document).on("click", "#save.save-donor-without-export", function(e) {
  var valid = $(this).parents("form:first").guard();
  var externalId = $("#donor_external_id").val();

  if (!$.guards.isPresent(externalId)) {
    externalIdGuard.triggerError("#donor_external_id");

    if (valid) {
      $("#donor_external_id").focus();
    }

    valid = false;
  }

  if (!valid) {
    e.preventDefault();
  }
});

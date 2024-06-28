const onExternalIdChange = function() {
  var value = $(this).val();
  $(".disable-on-external-id-change").prop("disabled", value !== "");
};

$(document).on("change", ".external-id-field", onExternalIdChange);
$(document).on("keyup", ".external-id-field", onExternalIdChange);

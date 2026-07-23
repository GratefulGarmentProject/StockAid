$(document).on("click", ".move-bins-button", function() {
  const button = $(this);
  const data = { url: button.data("move-bins-url"), display: button.data("bin-location-display") };
  $("#move-bins-modal-content").html(tmpl("move-bins-modal-content-template", data));
  $("#move-bins-modal").modal("show");
});

$(document).on("click", ".load-netsuite-unassigned-counties", function() {
  var button = $(this);
  button.prop("disabled", true);

  $.ajax({
    url: "/counties/unassigned",
    type: "GET",
    success: function(response) {
      $("#netsuite-unassigned-counties").html(response);
      $("#netsuite-unassigned-counties .data-table").setupDataTable();
      button.prop("disabled", false);
    },
    error: function() {
      $("#netsuite-unassigned-counties").html('<span class="text-danger">There was an error loading NetSuite counties.</span>');
      button.prop("disabled", false);
    }
  });
});

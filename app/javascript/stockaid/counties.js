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

$(document).on("click", ".load-netsuite-assigned-counties", function() {
  var button = $(this);
  button.prop("disabled", true);

  $.ajax({
    url: "/counties/assigned",
    type: "GET",
    dataType: "json",
    success: function(data) {
      for (var i = 0; i < data.counties.length; i++) {
        var county = data.counties[i];
        $("td.netsuite-county[data-external-id='" + county.external_id + "']").text(county.name);
      }

      button.prop("disabled", false);
    },
    error: function() {
      $("#netsuite-assigned-counties-error").html('<span class="text-danger">There was an error loading NetSuite counties.</span>');
      button.prop("disabled", false);
    }
  });
});

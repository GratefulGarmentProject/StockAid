function populateOrderDetailsModal(orderId) {
  var orderInfo = ORDERS[orderId];

  $("#order_id").text(orderInfo['order_id']);
  $("#date_received").text(orderInfo['date_received']);

  $("#organization_name").text(orderInfo['organization_name']);
  $("#status").text(orderInfo['status']);

  var orderDetails = orderInfo['order_details'];
  var html = [];
  $.each(orderDetails, function(key, val) {
    html.push("<tr><td>" + key + "</td><td>" + val + "</td></tr>");
  });
  $("#order-details").html(html.join(""));

  $("#order_details_modal").modal();
}

$(document).on("click", ".order", function() {
  populateOrderDetailsModal($(this).data("order-id"));
});

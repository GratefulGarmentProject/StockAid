$ ->
  showOrderDialog = (orderId) ->
    $.ajax
      url: "/orders/#{orderId}/show_order_dialog"
      type: 'POST'
      dataType: 'json'
      success: (response) ->
        $("#order_id").text(response.order_id)
        $("#date_received").text(response.order_date)
        $("#organization_name").text(response.organization_name)
        $("#status").text(response.status)
        $("#edit_order_button").attr("href", "/orders/" + response.order_id + "/edit")

        orderDetails = JSON.parse(response.order_details)
        html = []
        html.push("<tr><td>#{item.description}</td><td>#{item.quantity}</td></tr>") for item in orderDetails
        $("#order-details").html(html.join(""));
        $("#order_details_modal").modal();

      error: (jqXHR, textStatus, errorThrown) ->
        alert("Error occurred")


  $('.order').click (e) ->
    e.stopPropagation()
    orderId = $(e.target).parent().data('order-id')
    showOrderDialog(orderId)

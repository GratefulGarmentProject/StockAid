showOrderDialog = (orderId) ->
  $.ajax
    url: "/orders/#{orderId}/show_order_dialog"
    type: "POST"
    dataType: "json"
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

window.orderRowClicked = (event, row, element) ->
  event.stopPropagation()
  orderId = row.data("order-id")
  showOrderDialog(orderId)

populateCategories = (element) ->
  i = 0
  categories = []
  while i < data.categories.length
    category = data.categories[i]
    categories.push '<option value="' + category.id + '">' + category.description + '</option>'
    i++
  j = 0
  while j < categories.length
    $('#category').append categories[j]
    j++

populateItems = (category_id) ->
  i = 0
  logger
  items = data.categories[category_id].items
  items_html = []
  while i < items.length
    item = items[i]
    items_html.push '<option value="' + item.id + '">' + item.description + '</option>'
    i++
  j = 0

  $('#item').empty()
  $('#item').append '<option value="">Select an item...</option>'
  while j < items.length
    $('#item').append items_html[j]
    j++

$(document).on "change", ':input[name="status"]', (e) ->
  $(e.target).closest("form").submit()

$(document).on "click", ".add-item", (e) ->
  e.preventDefault()
  e.stopPropagation()
  $("#add_inventory_modal").modal("show")

$(document).on "click", "#add-item-row", (e) ->
  event.preventDefault();
  newRow = $('<tr class="order"><td><select id="category" class="form-control"><option value="">Select a category...</option></select></td><td><select id="item" class="form-control"><option value="">Select an item...</option></select></td><td><select id="quantity" class="form-control"><option value="">0</option></select></td></tr>');
  $('table tbody').append newRow

$(document).on 'page:change', ->
  populateCategories()

# $(document).on 'page:change', ->
$(document).on 'page:change', ->
  $('#category').on 'change', ->
    # console.log("this = " + this);
    populateItems(this.value)

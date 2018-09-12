order_item_class = (requested, available) ->
  return 'danger' if requested > available

populateItems = (category_id, element) ->
  id = parseInt category_id
  for category in data.categories
    if category.id is id
      currentCategory = category
  element.html tmpl("orders-item-options-template", currentCategory)

populateQuantity = (selected, element) ->
  totalAvailableQuantity = selected.data("available-quantity")
  element.attr("data-guard", "required int")
  element.attr("data-guard-int-min", "1").data("guard-int-min", 1)
  element.attr("data-guard-int-max", totalAvailableQuantity).data("guard-int-max", totalAvailableQuantity)

  element.val("").clearErrors()

populateQuantityAvailable = (selected, element) ->
  totalAvailableQuantity = selected.data("available-quantity")
  element.text(totalAvailableQuantity)

addOrderRow = (orderDetails) ->
  $("#order-table tbody").append tmpl("orders-new-order-template", {})
  return unless orderDetails

  row = $("#order-table tbody tr:last")
  category = row.find(".category")
  item = row.find(".item")
  quantity = row.find(".quantity")

  category.val orderDetails.category_id
  category.trigger "change"
  item.val orderDetails.item_id
  item.trigger "change"
  quantity.val orderDetails.quantity

expose "addOrderRows", ->
  $ ->
    added = false

    for orderDetail in data.order.order_details
      continue if orderDetail.quantity == 0
      added = true
      addOrderRow(orderDetail)

    addOrderRow() unless added

expose "loadAvailableQuantities", ->
  orderQuantityMap = {}

  if data.order.in_requested_status
    for details in data.order.order_details
      orderQuantityMap[details.item_id] = details.quantity

  for category in data.categories
    for item in category.items
      item.available_quantity = item.current_quantity - item.requested_quantity
      item.available_quantity += orderQuantityMap[item.id] || 0

addTrackingRow = ->
  $("#shipments-table tbody").append tmpl("orders-new-tracking-row-template", {})
  $("#shipments-table").show()

printOrder = ->
  window.print()

$(document).on "click", ".add-item", (event) ->
  event.preventDefault()
  event.stopPropagation()
  $("#add_inventory_modal").modal("show")

$(document).on "click", "#add-item-row", (event) ->
  event.preventDefault()
  addOrderRow()

$(document).on "click", ".delete-row", (event) ->
  event.preventDefault()
  $(@).parents("tr:first").remove()
  addOrderRow() if $("#order-table tbody tr").length == 0

$(document).on "click", "#print-order", (event) ->
  printOrder()

$(document).on "click", "#add-tracking-number", (event) ->
  event.preventDefault()
  addTrackingRow()

toggleDropshipCheckbox = ->
  if $("#dropship-input").attr('checked') == 'checked'
    $("#dropship-input").removeAttr('checked')
  else
    $("#dropship-input").attr('checked', true)

$(document).on "click", "#dropship-container", ->
  toggleDropshipCheckbox()

$(document).on "click", "button.suggested-name", ->
  $("#order_ship_to_name").val $(@).text()

$(document).on "click", "button.suggested-address", ->
  $("#order_ship_to_address").val $(@).text()

$(document).on "change", ".order-row .category", ->
  item_element = $(@).parents(".order-row").find ".item"
  populateItems $(@).val(), item_element

$(document).on "change", ".order-row .item", ->
  quantity_element = $(@).parents(".order-row").find ".quantity"
  quantity_available_element = $(@).parents(".order-row").find ".quantity-available"
  selected = $(@).find('option:selected')
  populateQuantity selected, quantity_element
  populateQuantityAvailable selected, quantity_available_element

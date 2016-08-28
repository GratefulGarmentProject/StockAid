order_item_class = (requested, available) ->
  return 'danger' if requested > available

populateItems = (category_id, element) ->
  id = parseInt category_id
  for category in data.categories
    if category.id is id
      currentCategory = category
  element.empty()
  element.append """<option value="">Select an item...</option>"""
  for {id, description, current_quantity, requested_quantity} in currentCategory.items
    element.append """<option value="#{id}" data-current-quantity="#{current_quantity}" data-requested-quantity="#{requested_quantity}">#{description}</option>"""

populateQuantity = (selected, element) ->
  available_quantity = selected.data("current-quantity") - selected.data("requested-quantity")
  element.attr("data-guard", "required int")
  element.attr("data-guard-int-min", "1").data("guard-int-min", 1)
  element.attr("data-guard-int-max", available_quantity).data("guard-int-max", available_quantity)

  element.val("").clearErrors()

populateQuantityAvailable = (selected, element) ->
  available_quantity = selected.data("current-quantity") - selected.data("requested-quantity")
  element.text(available_quantity)

window.setOrderRow = (order_details) ->
  row = $("#order-table tbody tr:last")
  category = row.find(".category")
  item = row.find(".item")
  quantity = row.find(".quantity")

  category.val order_details.category_id
  category.trigger "change"
  item.val order_details.item_id
  item.trigger "change"
  quantity.val order_details.quantity

window.addOrderRow = ->
  $("#order-table tbody").append tmpl("orders-new-order-template", {})

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

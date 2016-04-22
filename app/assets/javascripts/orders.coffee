order_item_class = (requested, available) ->
  return 'danger' if requested > available

populateCategories = (element) ->
  for {id, description} in data.categories
    element.append """<option value="#{id}">#{description}</option>"""

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
  newRow = $ """
    <tr class="order-row">
      <td>
        <div class="form-group">
          <select class="category form-control" data-guard="required">
            <option value="">Select a category...</option>
          </select>
        </div>
      </td>
      <td>
        <div class="form-group">
          <select name="order[order_details][item_id][]" class="item form-control" data-guard="different required">
            <option value="">Select an item...</option>
          </select>
        </div>
      </td>
      <td>
        <div class="form-group">
          <input type="number" name="order[order_details][quantity][]" class="quantity form-control" placeholder="Select an Item..." data-guard="required" />
        </div>
      </td>
      <td class="text-muted">
        <p class="quantity-available form-control-static">
        </p>
      </td>
      <td>
        <button class="pull-right btn btn-danger btn-xs delete-row">
          <span class="glyphicon glyphicon-trash"></span>
        </button>
      </td>
    </tr>
  """

  category = newRow.find ".category"
  populateCategories category
  $("#order-table tbody").append newRow

addTrackingRow = ->
  newRow = $ """
    <tr>
      <td>
        <div class="form-group">
          <input type="text" name="order[shipments][tracking_number][]" class="form-control" placeholder="Enter a new tracking number" data-guard="required" />
        </div>
      </td>

      <td>
        <div class="form-group">
          <select name="order[shipments][shipping_carrier][]" class="form-control" data-guard="required">
            <option value="">Please choose ...</option>
          </select>
        </div>
      </td>

      <td></td>

      <td>
        <button class="pull-right btn btn-danger btn-xs delete-row">
          <span class="glyphicon glyphicon-trash"></span>
        </button>
      </td>
    </tr>
  """

  carriers = newRow.find "select"

  for carrier, value of data.validCarriers
    option = $ """<option></option>"""
    option.attr "value", value
    option.text carrier
    carriers.append option

  $("#shipments-table tbody").append newRow
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

$(document).on "change", ".order-row .category", ->
  item_element = $(@).parents(".order-row").find ".item"
  populateItems $(@).val(), item_element

$(document).on "change", ".order-row .item", ->
  quantity_element = $(@).parents(".order-row").find ".quantity"
  quantity_available_element = $(@).parents(".order-row").find ".quantity-available"
  selected = $(@).find('option:selected')
  populateQuantity selected, quantity_element
  populateQuantityAvailable selected, quantity_available_element

$(document).on "page:change", ->
  addOrderRow() if $("#order-table").length == 0

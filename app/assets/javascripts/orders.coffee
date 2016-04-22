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
  if selected.val() == ""
    element.attr("placeholder", "Select an Item...")
    element.removeAttr("data-guard data-guard-int-min data-guard-int-max")
    element.attr("data-guard", "required")
  else
    available_quantity = selected.data("current-quantity") - selected.data("requested-quantity")
    element.attr("placeholder", "#{available_quantity} available")
    element.attr("data-guard", "required int")
    element.attr("data-guard-int-min", "1").data("guard-int-min", 1)
    element.attr("data-guard-int-max", available_quantity).data("guard-int-max", available_quantity)

  element.val("").clearErrors()

addNewOrderRow = ->
  newRow = $("""
    <tr class="new-order-row">
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
          <input name="order[order_details][quantity][]" class="quantity form-control" placeholder="Select an Item..." data-guard="required" />
        </div>
      </td>
      <td>
        <button class="pull-right btn btn-danger btn-xs delete-row">
          <span class="glyphicon glyphicon-trash"></span>
        </button>
      </td>
    </tr>
  """)
  category = newRow.find ".category"
  populateCategories category
  $("#new-order-table tbody").append newRow

printOrder = ->
  window.print()

$(document).on "click", ".add-item", (event) ->
  event.preventDefault()
  event.stopPropagation()
  $("#add_inventory_modal").modal("show")

$(document).on "click", "#add-item-row", (event) ->
  event.preventDefault()
  addNewOrderRow()

$(document).on "click", ".delete-row", (event) ->
  event.preventDefault()
  $(@).parents("tr:first").remove()
  addNewOrderRow() if $("#new-order-table tbody tr").length == 0

$(document).on "click", "#print-order", (event) ->
  printOrder()

$(document).on "click", "#add-tracking-number", (event) ->
  event.preventDefault()
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

$(document).on "change", ".new-order-row .category", ->
  item_element = $(@).parents(".new-order-row").find ".item"
  populateItems $(@).val(), item_element

$(document).on "change", ".new-order-row .item", ->
  quantity_element = $(@).parents(".new-order-row").find ".quantity"
  selected = $(@).find('option:selected')
  populateQuantity selected, quantity_element

$(document).on "page:change", ->
  addNewOrderRow() if $("#new-order-table").length > 0

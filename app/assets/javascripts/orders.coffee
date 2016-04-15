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
    element.attr("data-guard", "mustOrderSomething")
  else
    available_quantity = selected.data("current-quantity") - selected.data("requested-quantity")
    element.attr("placeholder", "#{available_quantity} available")
    element.attr("data-guard", "mustOrderSomething required int")
    element.attr("data-guard-int-min", "1").data("guard-int-min", 1)
    element.attr("data-guard-int-max", available_quantity).data("guard-int-max", available_quantity)

  element.val("").clearErrors()

addNewOrderRow = ->
  currentNumRows = $("#new-order-table tbody").find("tr").length
  newRow = $("""
    <tr class="new-order-row">
      <td>
        <div class="form-group">
          <select class="category form-control row-#{currentNumRows}">
            <option value="">Select a category...</option>
          </select>
        </div>
      </td>
      <td>
        <div class="form-group">
          <select name="order_detail[#{currentNumRows}][item_id]" class="item form-control row-#{currentNumRows}" data-guard="different">
            <option value="">Select an item...</option>
          </select>
        </div>
      </td>
      <td>
        <div class="form-group">
          <input name="order_detail[#{currentNumRows}][quantity]" class="quantity form-control row-#{currentNumRows}" placeholder="Select an Item..." data-guard="mustOrderSomething" />
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

$(document).on "click", "#add-tracking-number", (event) ->
  event.preventDefault()
  newRow = $ """
    <tr>
      <td>
        <div class="form-group">
          <input type="text" name="tracking_number[]" class="form-control" placeholder="Enter a new tracking number" data-guard="required" />
        </div>
      </td>

      <td>
        <div class="form-group">
          <select name="shipping_carrier[]" class="form-control" data-guard="required">
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

$.guards.name("mustOrderSomething").grouped().message("You must order at least one thing.").using (values, elements) ->
  $.guards.isAnyValid elements, (element) ->
    container = $(element).parents(".new-order-row:first")
    category = container.find("select.category").val()
    item = container.find("select.item").val()
    value = container.find("input.quantity").val()
    $.guards.isPresent(category) && $.guards.isPresent(item) && $.guards.isPresent(value)

showOrderDialog = (orderId) ->
  $.ajax
    url: "/orders/#{orderId}/show_order_dialog"
    type: "POST"
    dataType: "json"
    success: ({order_id, user, organization, order_date, status, order_details}) ->
      $("#order_id").text order_id
      $("#user_name").text user.name
      $("#email").text user.email
      $("#primary_number").text user.primary_number
      $("#secondary_number").text user.secondary_number
      $("#organization_name").text organization.name
      $("#county").text organization.county
      $("#address").text user.address
      $("#date_received").text order_date
      $("#status").text status
      $("#edit_order_button").attr "href", "/orders/#{order_id}/edit"

      orderDetails = JSON.parse(order_details)
      html = []
      for item in orderDetails
        html.push("""
          <tr class="#{order_item_class(item.quantity_ordered, item.quantity_available)}">
            <td>#{item.description}</td><td>#{item.quantity_ordered}</td>
          </tr>""")

      $("#order-details").html html.join("")
      # Disable the approve button if we have a problem
      if $("#order-details tr.danger").length
        $("#order_details_modal #order_approve").attr("disabled","disabled")
      else
        $("#order_details_modal #order_approve").removeAttr("disabled")

      $("#order_details_modal").modal()
    error: (jqXHR, textStatus, errorThrown) ->
      alert "Error occurred"

order_item_class = (requested, available) ->
  return 'danger' if requested > available

expose "orderRowClicked", (event, row, element) ->
  event.stopPropagation()
  orderId = row.data "order-id"
  showOrderDialog orderId

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

populateQuantity = (current_quantity, requested_quantity, element) ->
  available_quantity = parseInt(current_quantity) - parseInt(requested_quantity)
  element.val("")
  element.attr("placeholder", "#{available_quantity} available")
  element.attr("data-guard", "required int")
  element.attr("data-guard-int-min", "1")
  element.attr("data-guard-int-max", available_quantity)

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
          <select name="order_detail[#{currentNumRows}][item_id]" class="item form-control row-#{currentNumRows}">
            <option value="">Select an item...</option>
          </select>
        </div>
      </td>
      <td>
        <div class="form-group">
          <input name="order_detail[#{currentNumRows}][quantity]" class="quantity form-control row-#{currentNumRows}" placeholder="Select an Item..."/>
        </div>
      </td>
    </tr>
  """)
  category = newRow.find ".category"
  populateCategories category
  $("#new-order-table tbody").append newRow

toggleAddTrackingFields = ->
  $("#add-tracking-info").toggle()

modifyElementText = (element, text) ->
  $(element).text(text)

$(document).on "click", ".add-item", (event) ->
  event.preventDefault()
  event.stopPropagation()
  $("#add_inventory_modal").modal("show")

$(document).on "click", "#add-item-row", (event) ->
  event.preventDefault()
  addNewOrderRow()

$(document).on "click", "#add-tracking-number", (event) ->
  event.preventDefault()
  console.log($(@).text())
  if $(@).text() == "Hide Add Tracking"
    modifyElementText(@, "Add Tracking")
  else
    modifyElementText(@, "Hide Add Tracking")
  toggleAddTrackingFields()

$(document).on "change", ".new-order-row .category", ->
  item_element = $(@).parents(".new-order-row").find ".item"
  populateItems $(@).val(), item_element

$(document).on "change", ".new-order-row .item", ->
  quantity_element = $(@).parents(".new-order-row").find ".quantity"
  selected = $(@).find('option:selected')
  populateQuantity selected.data("current-quantity"), selected.data("requested-quantity"), quantity_element

$(document).on "page:change", ->
  addNewOrderRow() if $("#new-order-table").length > 0
  toggleAddTrackingFields() if $("#add-tracking-info").length > 0

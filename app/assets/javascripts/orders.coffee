showOrderDialog = (orderId) ->
  $.ajax
    url: "/orders/#{orderId}/show_order_dialog"
    type: "POST"
    dataType: "json"
    success: ({order_id, order_date, organization_name, status, order_details}) ->
      $("#order_id").text order_id
      $("#date_received").text order_date
      $("#organization_name").text organization_name
      $("#status").text status
      $("#edit_order_button").attr "href", "/orders/#{order_id}/edit"
      orderDetails = JSON.parse(order_details)
      html = []
      html.push("<tr><td>#{item.description}</td><td>#{item.quantity}</td></tr>") for item in orderDetails
      $("#order-details").html html.join("")
      $("#order_details_modal").modal()
    error: (jqXHR, textStatus, errorThrown) ->
      alert "Error occurred"

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
  for {id, description} in currentCategory.items
    element.append """<option value="#{id}">#{description}</option>"""

addNewOrderRow = ->
  currentNumRows = $("#new-order-table tbody").find("tr").length
  newRow = $("""
    <tr class="new-order-row">
      <td>
        <select class="category form-control row-#{currentNumRows}">
          <option value="">Select a category...</option>
        </select>
      </td>
      <td>
        <select class="item form-control row-#{currentNumRows}">
          <option value="">Select an item...</option>
        </select>
      </td>
      <td>
        <select class="quantity form-control row-#{currentNumRows}">
          <option value="">0</option>
        </select>
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

$(document).on "change", ".new-order-row .category", ->
  item_element = $(@).parents(".new-order-row").find ".item"
  populateItems $(@).val(), item_element

$(document).on "page:change", ->
  addNewOrderRow() if $("#new-order-table").length > 0


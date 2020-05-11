UPDATE_REMAINING_EVENT = "update.remaining"

$(document).on "keyup keypress", (event) ->
  keyCode = event.keyCode || event.which
  if keyCode == 13
    event.preventDefault()
    return false

populateItems = (category_id, element) ->
  id = parseInt category_id
  for category in data.categories
    if category.id is id
      currentCategory = category
  element.html tmpl("purchases-item-options-template", currentCategory)

addPurchaseRow = (purchaseDetail) ->
  # Add an empty row
  data.num_rows = $(".purchase-row").length
  $("#purchase-table > tbody").append tmpl("purchases-new-purchase-template", purchaseDetail)
  return unless purchaseDetail

  purchaseDetail.original_quantity_remaining = purchaseDetail.quantity_remaining
  # Populate that row if there are purchaseDetail
  row = $("#purchase-table > tbody > tr.purchase-row:last")
  purchaseDetailId = row.find(".purchase_detail_id")
  category = row.find(".category")
  item = row.find(".item")
  quantity = row.find(".quantity")
  cost = row.find(".cost")
  variance = row.find(".variance")
  itemValue = row.find(".item_value")
  showHideShipmentsButton = row.find(".show-shipment-table")

  purchaseDetailId.val purchaseDetail.id
  category.val purchaseDetail.item.category.id
  category.trigger "change"
  item.val purchaseDetail.item.id
  item.trigger "change"
  quantity.val purchaseDetail.quantity
  cost.val formatMoney(purchaseDetail.cost)
  variance.val formatMoney(purchaseDetail.variance)
  itemValue.val purchaseDetail.item.value
  quantity.trigger "change"
  cost.trigger "change"

  purchaseShipmentTableRow = $("#purchase-table > tbody > tr.purchase-shipment-table-row:last > td")
  purchaseShipmentTableRow.html tmpl("purchases-purchase-shipment-table-template", { purchaseDetailId: purchaseDetail.id, quantityRemaining: purchaseDetail.quantity_remaining })
  if purchaseDetail.purchase_shipments
    showHideShipmentsButton.prop('disabled', false)
    for purchaseShipment, index in purchaseDetail.purchase_shipments
      addPurchaseShipmentRow(purchaseShipmentTableRow, purchaseDetail.id, purchaseShipment, index)
  else
    # Add a blank row
    emptyPurchaseDetail = {
      quantity_received: purchaseDetail.quantity_remaining
    }
    purchaseDetail.quantity_remaining = 0

    addPurchaseShipmentRow(purchaseShipmentTableRow, purchaseDetail.id, emptyPurchaseDetail)

addPurchaseShipmentRow = (currentRow, purchaseDetailId, purchaseShipment, purchaseShipmentRowIndex = null) ->
  # simpler than the above since there's no live selects
  tableBody = currentRow.find(".purchase-shipments-table > tbody")
  if !purchaseShipmentRowIndex
    purchaseShipmentRowIndex = tableBody.find("tr.purchase-shipment-row").length

  dataForThisRow = Object.assign({}, purchaseShipment, { index: purchaseShipmentRowIndex+1, purchaseDetailId })
  tableBody.append tmpl("purchases-purchase-shipment-row-template", dataForThisRow)

expose "addPurchaseRows", ->
  $ ->
    if data.purchase && data.purchase.purchase_details && data.purchase.purchase_details.length > 0
      for purchaseDetail in data.purchase.purchase_details
        continue if purchaseDetail.quantity == 0
        addPurchaseRow(purchaseDetail)
    else
      # Add a blank row unless we have already added content to the table
      addPurchaseRow()

# addTrackingRow = ->
#   $("#shipments-table tbody").append tmpl("purchases-new-tracking-row-template", {})
#   $("#shipments-table").show()

printOrder = ->
  window.print()

calculateLineCostAndVariance = (activeElement) ->
  purchaseRow = activeElement.parents(".purchase-row")
  quantityElement = purchaseRow.find ".quantity"
  costElement = purchaseRow.find ".cost"
  lineCostElement = purchaseRow.find ".line-cost"
  varianceElement = purchaseRow.find ".variance"
  itemValue = getCurrentItemValue(purchaseRow)

  lineCost = costElement.val() * quantityElement.val()
  variance = costElement.val() - itemValue
  lineCostElement.val(formatMoney(lineCost))
  varianceElement.val(formatMoney(variance) + " (from " + formatMoney(itemValue) + ")")

calcuateSubtotal = ->
  lineCostElements = $(".line-cost")
  subtotal = 0
  for element in lineCostElements
    subtotal += parseFloat($(element).val())

  $(".subtotal").val(formatMoney(subtotal))

calculateTotal = ->
  subTotal = parseFloat($("#blank_subtotal").val())
  tax = parseFloat($("#purchase_tax").val())
  shipping = parseFloat($("#purchase_shipping_cost").val())
  $("#blank_total").val(formatMoney(subTotal + tax + shipping))

expose "disableFormWhenClosed", ->
  $ ->
    if (data.purchase && data.purchase.status && data.purchase.status == "closed")
      $("input").prop("disabled", true)
      $("select").prop("disabled", true)
      $("button#purchase-add-row").prop("disabled", true)
      $("button.delete-purchase-row").prop("disabled", true)

findPurchaseDetail = (purchaseDetailId) ->
  details = data.purchase.purchase_details
  for detail in details
    return detail if detail.id == purchaseDetailId
  return null

expose "formatTotalsBlock", ->
  $ ->
    subtotalElement = $("input.subtotal")
    subtotalElement.val(formatMoney(subtotalElement.val()))
    taxElement = $("input.tax")
    taxElement.val(formatMoney(taxElement.val()))
    shippingCostElement = $("input.shipping-cost")
    shippingCostElement.val(formatMoney(shippingCostElement.val()))
    totalElement = $("input.total")
    totalElement.val(formatMoney(totalElement.val()))

getCurrentItemValue = (row) ->
  itemElement = row.find(".item")
  optionSelected = itemElement.find("option:selected")
  itemValue = optionSelected.data().itemValue
  return itemValue

expose "setVendorInfo", ->
  $ ->
    if data.purchase && data.purchase.vendor_id
      vendor = $("#purchase_vendor_id")
      vendor.val = data.purchase.vendor_id
      vendor.trigger "change"

updateQuantityRemaining = (shipmentRow, purchaseDetail) ->
  quantitiyRemaining = shipmentRow
    .closest("table")
    .find("tfoot")
    .find("span.displayed-quantity-remaining")
  quantitiyRemaining.html(purchaseDetail.quantity_remaining)

updateVendorInfo = (selectedVendorId) ->
  vendors = data.vendors
  for vendor in vendors
    if parseInt(vendor.id) == parseInt(selectedVendorId)
      $(".vendor-website").html(vendor.website)
      $(".vendor-phone").html(vendor.phone_number)
      $(".vendor-email").html(vendor.email)
      $(".vendor-contact-name").html(vendor.contact_name)

# Add an empty row
$(document).on "click", "#purchase-add-row", (event) ->
  event.preventDefault()
  addPurchaseRow()

# Delete the row
$(document).on "click", ".delete-purchase-row", (event) ->
  event.preventDefault()
  parent = $(@).parents("tr:first")
  rowData = {}
  rowData["rowName"] = parent.find(".purchase_detail_id").prop("name")
  rowData["rowValue"] = parent.find(".purchase_detail_id").val()
  rowData["destroyName"] = rowData["rowName"].replace("[id]", "[_destroy]")
  parent.remove()
  $("#purchase-table tbody").append tmpl("delete-purchase-detail-row-template", rowData)
  # Add a balnk row if user deleted the only row
  addPurchaseRow() if $("#purchase-table tbody tr").length == 0

# Toggle the shipments table for a row
$(document).on "click", ".show-shipment-table", (event) ->
  event.preventDefault()
  purchaseShipmentRow = $(@).parents(".purchase-row").next()
  purchaseShipmentRow.toggleClass("hidden")

# Add a new purchase shipment row
$(document).on "click", ".purchases-purchase-detail-add-shipment-button", (event) ->
  event.preventDefault()
  purchaseDetailId = $(@).data("forPurchaseDetailId")
  purchassShipmentTableRow = $(@).parents(".purchase-shipment-table-row")
  detail = findPurchaseDetail(purchaseDetailId)
  newPurchaseShipment = {
    quantity_received: detail.quantity_remaining
  }
  detail.quantity_remaining = 0
  addPurchaseShipmentRow(purchassShipmentTableRow, purchaseDetailId, newPurchaseShipment)
  shipmentRow = purchassShipmentTableRow.find("table > tbody > tr:last")
  updateQuantityRemaining(shipmentRow, detail)

$(document).on "change", "input.quantity-received", (event) ->
  # update the quantity remaining
  shipmentRow = $(@).parents(".purchase-shipment-row")
  purchaseDetailId = parseInt(shipmentRow.data("forPurchaseDetail"))
  newNumber = parseInt(event.target.value)
  detail = findPurchaseDetail(purchaseDetailId)
  return if !detail
  detail.quantity_remaining = detail.original_quantity_remaining - newNumber
  updateQuantityRemaining(shipmentRow, detail)

# Delete a shipment row
#$(document).on "click", ".delete-this-shipment-button", (event) ->
#  event.preventDefault()
#  purchaseShipmentRow = $(@).parents(".purchase-shipment-row")
#  rowData = {}
#  rowData[""]

# Print the Purhcase
$(document).on "click", "#print-purchase", (event) ->
  printOrder()

# $(document).on "click", "#add-tracking-number", (event) ->
#   event.preventDefault()
#   addTrackingRow()

$(document).on "click", "button.suggested-name", ->
  $("#purchase_ship_to_name").val $(@).text()

$(document).on "click", "button.suggested-address", ->
  $("#purchase_ship_to_address").val $(@).text()

$(document).on "change", ".purchase-row .category", ->
  item_element = $(@).parents(".purchase-row").find ".item"
  populateItems $(@).val(), item_element

$(document).on "change", ".purchase-row .item", ->
  calculateLineCostAndVariance($(@))

$(document).on "change", ".purchase-row .quantity", ->
  calculateLineCostAndVariance($(@))
  calcuateSubtotal()
  calculateTotal()

$(document).on "change", ".purchase-row .cost", ->
  $(@).val(formatMoney($(@).val()))
  calculateLineCostAndVariance($(@))
  calcuateSubtotal()
  calculateTotal()

$(document).on "change", ".purchase-row .line-cost", ->
  purchaseRow = $(@).parents(".purchase-row")
  quantityElement = purchaseRow.find ".quantity"
  costElement = purchaseRow.find ".cost"
  lineCostElement = purchaseRow.find ".line-cost"
  itemValue = getCurrentItemValue(purchaseRow)

  cost = lineCostElement.val() / quantityElement.val()
  variance = cost - itemValue
  costElement.val(formatMoney(cost))
  varianceElement.val(formatMoney(variance) + " (from " + itemValue + ")")
  calcuateSubtotal()
  calculateTotal()

$(document).on "change", "#purchase_tax", ->
  tax = $(@).val()
  $(@).val(formatMoney(tax))
  calculateTotal()

$(document).on "change", "#purchase_shipping_cost", ->
  shipping = $(@).val()
  $(@).val(formatMoney(shipping))
  calculateTotal()

$(document).on "change", "#purchase_vendor_id", ->
  if parseInt($(@).val()) > 0
    updateVendorInfo($(@).val())
  else
    $(".vendor-website").html("")
    $(".vendor-phone").html("")
    $(".vendor-email").html("")

$(document).on UPDATE_REMAINING_EVENT, ".quantity-remaining", ->
  alert("Update Remaining")
  purchaseDetailId = $(@).data("purchaseId")
  detail = findPurchaseDetail(purchaseDetailId)
  $(@).html(detail.quantity_remaining)

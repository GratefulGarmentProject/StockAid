addPurchaseRow = (purchaseDetail) ->
  # Add an empty row
  data.num_rows = $(".purchase-row").length
  purchaseRowOptions = {
    rowGroupId: data.num_rows,
    id: if purchaseDetail then purchaseDetail.id else null
  }
  row = $("#purchase-table > tbody").append tmpl("purchase-row-template", purchaseRowOptions)

  $("select").select2(theme: "bootstrap", width: "100%")

  return unless purchaseDetail

  # Populate row if there are purchaseDetail
  purchaseDetail.original_quantity_remaining = purchaseDetail.quantity_remaining
  row = $("#purchase-table > tbody > tr.purchase-row:last")
  purchaseDetailId = row.find(".purchase_detail_id")
  category = row.find(".category")
  item = row.find(".item")
  quantity = row.find(".quantity")
  cost = row.find(".cost")
  variance = row.find(".price-point-variance")
  itemValue = row.find(".item_value")

  purchaseDetailId.val purchaseDetail.id
  category.val purchaseDetail.item.category.id
  category.trigger "change"
  item.val purchaseDetail.item.id
  item.trigger "change"
  quantity.val purchaseDetail.quantity
  cost.val formatMoney(purchaseDetail.cost)
  variance.val formatMoney(purchaseDetail.price-point-variance)
  itemValue.val purchaseDetail.item.value
  quantity.trigger "change"
  cost.trigger "change"

  purchaseShipmentTableRow = $("#purchase-table > tbody > tr.purchase-shipment-table-row:last")
  purchaseShipmentTableCell = purchaseShipmentTableRow.find("td")
  purchaseShipmentTableRowOptions = {
    rowGroupId: purchaseRowOptions.rowGroupId,
    purchaseDetailId: purchaseDetail.id,
    quantityRemaining: purchaseDetail.quantity_remaining
  }
  purchaseShipmentTableCell.html tmpl("purchase-shipment-table-template", purchaseShipmentTableRowOptions)
  if purchaseDetail.purchase_shipments.length > 0
    for purchaseShipment, index in purchaseDetail.purchase_shipments
      addPurchaseShipmentRow(purchaseShipmentTableRow, purchaseDetail.id, purchaseShipment, purchaseRowOptions.rowGroupId, index)

addPurchaseShipmentRow = (currentRow, purchaseDetailId, purchaseShipment, purchaseDetailRowGroupId, purchaseShipmentRowIndex = null) ->
  # simpler than the above since there's no live selects
  purchaseDetailIndex = currentRow.data("thisRowIndex")
  table = currentRow.find(".purchase-shipments-table")
  tableBody = table.find("tbody")
  if !purchaseShipmentRowIndex
    purchaseShipmentRowIndex = tableBody.find("tr.purchase-shipment-row").length

  dataForThisRow = Object.assign(
    {},
    purchaseShipment,
    {
      rowGroupId: purchaseDetailRowGroupId,
      index: purchaseShipmentRowIndex + 1,
      purchaseDetailId,
      purchaseDetailIndex
    }
  )
  tableBody.append tmpl("purchase-shipment-row-template", dataForThisRow)
  if (purchaseShipment && purchaseShipment.id)
    # this shipment has been saved
    tableBody.find("tr:last div.shipment-persisted-icon").removeClass("hidden")
    tableBody.find("tr:last button.delete-this-shipment-button").removeClass("hidden").prop("disabled", false)
  else
    tableBody.find("tr:last div.shipment-new-icon").removeClass("hidden")
  updateQuantityRemaining(table, findPurchaseDetail(purchaseDetailId))

calculateLineCostAndVariance = (activeElement) ->
  purchaseRow = activeElement.parents(".purchase-row")
  quantityElement = purchaseRow.find ".quantity"
  costElement = purchaseRow.find ".cost"
  lineCostElement = purchaseRow.find ".line-cost"
  varianceElement = purchaseRow.find ".price-point-variance"
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

calculateQuantityRemaining = (shipmentTable, purchaseDetail) ->
  shipments = shipmentTable.find(".purchase-shipment-row")
  shipped = 0
  shipments.each((idx, shipment) ->
    quantity = parseInt($(shipment).find(".quantity-received").val())
    shipped = shipped + quantity
  )
  purchaseDetail.quantity_remaining = purchaseDetail.quantity - shipped

deletePurchaseDetail = (purchaseRow) ->
  shipmentTableRow = purchaseRow.next()
  tableBody = purchaseRow.parent("tbody")
  idFieldName = purchaseRow.find(".purchase_detail_id").attr("name")
  destroyFieldName = idFieldName.replace("[id]", "[_destroy]")
  purchaseId = parseInt(purchaseRow.data("purchaseId"))
  templateData = {
    rowName: idFieldName,
    rowValue: purchaseId,
    destroyName: destroyFieldName
  }
  purchaseRow.remove()
  shipmentTableRow.remove()
  if !isNaN(purchaseId)
    tableBody.append(tmpl("deleted-purchase-row-template", templateData))
  if tableBody.find("tr").length == 0
    addPurchaseRow({})

deleteShipmentDetailRow = (shipmentRow) ->
  form = shipmentRow.closest("form")
  shipmentDetailId = shipmentRow.find(".purchase_detail_id").val()
  rowGroupId = shipmentRow.data("forPurchaseDetail")
  rowIndex = shipmentRow.data("shipmentRowIndex")
  purchaseDetailIndex = shipmentRow.data("purchaseDetailIndex")
  shipmentTableBody = shipmentRow.parent("tbody")
  templateData = {
    rowGroupId: rowGroupId,
    index: rowIndex,
    id: shipmentDetailId,
    purchaseDetailIndex
  }
  shipmentRow.remove()
  shipmentTableBody.append(tmpl("purchases-deleted-purchase-shipment-row-template", templateData))
  form.submit()

findPurchaseDetail = (purchaseDetailId) ->
  details = data.purchase.purchase_details
  for detail in details
    return detail if detail.id == purchaseDetailId
  return null

getCurrentItemValue = (row) ->
  itemElement = row.find(".item")
  optionSelected = itemElement.find("option:selected")
  itemValue = optionSelected.data().itemValue
  return itemValue

populateItems = (category_id, element) ->
  id = parseInt category_id
  for category in data.categories
    if category.id is id
      currentCategory = category
  element.html tmpl("purchase-item-options-template", currentCategory)

printOrder = ->
  window.print()

updateQuantityRemaining = (shipmentTable, purchaseDetail) ->
  foot = shipmentTable
    .find("tfoot")
  quantitiyRemaining =
    foot.find("span.displayed-quantity-remaining")
  quantitiyRemaining.html(calculateQuantityRemaining(shipmentTable, purchaseDetail))
  foot
    .find("button.purchases-purchase-detail-add-shipment-button")
    .prop("disabled", (purchaseDetail.quantity_remaining == 0))

updateVendorInfo = (selectedVendorId) ->
  vendors = data.vendors
  for vendor in vendors
    if parseInt(vendor.id) == parseInt(selectedVendorId)
      $(".vendor-website").html(vendor.website)
      $(".vendor-phone").html(vendor.phone_number)
      $(".vendor-email").html(vendor.email)
      $(".vendor-contact-name").html(vendor.contact_name)

################
# Form Disable #
################

expose "disableFormWhenClosed", ->
  $ ->
    if (data.purchase && data.purchase.status && data.purchase.status == "closed")
      $("input").prop("disabled", true)
      $("select").prop("disabled", true)
      $("button#purchase-add-row").prop("disabled", true)
      $("button.delete-purchase-row").prop("disabled", true)

#############################
# Vendor selection and info #
#############################

expose "initializeVendors", ->
  defaultMatcher = $.fn.select2.defaults.defaults.matcher

  $ ->
    $("#purchase_vendor_id").select2
      theme: "bootstrap"
      width: "100%"
      matcher: (params, data) ->
        textToMatch = data.element.getAttribute("data-search-text") || ""

        if defaultMatcher(params, { text: textToMatch })
          data
        else
          null

expose "setVendorInfo", ->
  $ ->
    if data.purchase && data.purchase.vendor_id
      vendor = $("#purchase_vendor_id")
      vendor.val = data.purchase.vendor_id
      vendor.trigger "change"

$(document).on "change", "#purchase_vendor_id", ->
  if parseInt($(@).val()) > 0
    updateVendorInfo($(@).val())
  else
    $(".vendor-website").html("")
    $(".vendor-phone").html("")
    $(".vendor-email").html("")
    $(".vendor-contact-name").html("")
    $("input#purchase_po").val = ""

#########################
# Return/Enter Escaping #
#########################

$(document).on "keyup keypress", (event) ->
  keyCode = event.keyCode || event.which
  if keyCode == 13
    event.preventDefault()
    return false

####################
# Categories/Items #
####################

$(document).on "page:change", ->
  $(".purchase-category .select2").select2({ theme: "bootstrap", width: "100%" })
  $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"})

$(document).on "click", ".add-purchase-detail-fields", (e) ->
  e.preventDefault()
  time = new Date().getTime()
  link = e.target
  linkId = link.dataset.id
  regexp = if linkId then new RegExp(linkId, 'g') else null
  newFields = if regexp then link.dataset.fields.replace(regexp, time) else null
  if newFields then $(".purchase-rows").append(newFields) else null

$(document).on "change", "#category", ->
  item_element = $(@).parents(".purchase-row").find(".item")
  if $(@).val() == undefined
    $(item_element).prop('disabled', true)
  else
    populateItems($(@).val(), item_element)
    $(item_element).removeAttr('disabled')
  $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"})

$(document).on "change", ".purchase-row .item", ->
  calculateLineCostAndVariance($(@))

$(document).on "change", ".purchase-row .quantity", ->
  calculateLineCostAndVariance($(@))
  calcuateSubtotal()
  calculateTotal()

$(document).on "update.remaining", ".quantity-remaining", ->
  alert("Update Remaining")
  purchaseDetailId = $(@).data("purchaseId")
  detail = findPurchaseDetail(purchaseDetailId)
  $(@).html(detail.quantity_remaining)

#################
# Purchase Rows #
#################

expose "addPurchaseRows", ->
  $ ->
    if data.purchase && data.purchase.purchase_details && data.purchase.purchase_details.length > 0
      for purchaseDetail in data.purchase.purchase_details
        continue if purchaseDetail.quantity == 0
        addPurchaseRow(purchaseDetail)
    else
      # Add a blank row unless we have already added content to the table
      addPurchaseRow()

# Add an empty purchase detail row
$(document).on "click", "#purchase-add-row", (event) ->
  event.preventDefault()
  addPurchaseRow()

# Delete a purchase detail row
$(document).on "click", ".delete-purchase-row", (event) ->
  event.preventDefault()
  purchaseRow = $(@).closest("tr.purchase-row")
  deletePurchaseDetail(purchaseRow)


#############
# Shipments #
#############

# Toggle the shipments table for a row
$(document).on "click", ".toggle-shipment-table", (event) ->
  event.preventDefault()
  purchaseShipmentRow = $(@).parents(".purchase-row").next()
  purchaseShipmentRow.toggleClass("hidden")

# Add a new purchase shipment row
$(document).on "click", ".purchases-purchase-detail-add-shipment-button", (event) ->
  event.preventDefault()
  purchaseDetailId = $(@).data("forPurchaseDetailId")
  purchaseDetailRowGroupId = $(@).data("rowGroupId")
  purchassShipmentTableRow = $(@).parents(".purchase-shipment-table-row")
  detail = findPurchaseDetail(purchaseDetailId)
  newPurchaseShipment = {
    quantity_received: detail.quantity_remaining
  }
  detail.quantity_remaining = 0
  addPurchaseShipmentRow(purchassShipmentTableRow, purchaseDetailId, newPurchaseShipment, purchaseDetailRowGroupId )
  shipmentTable = purchassShipmentTableRow.find("table")
  updateQuantityRemaining(shipmentTable, detail)

$(document).on "click", ".delete-this-shipment-button", (event) ->
  shipmentRow = $(@).closest("tr.purchase-shipment-row")
  deleteShipmentDetailRow(shipmentRow)

$(document).on "change", "input.quantity-received", (event) ->
  # update the quantity remaining
  shipmentRow = $(@).parents(".purchase-shipment-row")
  purchaseDetailId = parseInt(shipmentRow.data("forPurchaseDetail"))
  newNumber = parseInt(event.target.value)
  detail = findPurchaseDetail(purchaseDetailId)
  return if !detail
  detail.quantity_remaining = detail.original_quantity_remaining - newNumber
  updateQuantityRemaining(shipmentRow.closest("table"), detail)

######################
# Print the Purhcase #
######################

$(document).on "click", "#print-purchase", (event) ->
  printOrder()

################
# Calculations #
################

$(document).on "change", ".purchase-row .cost", ->
  $(@).val(formatMoney($(@).val()))
  calculateLineCostAndVariance($(@))
  calcuateSubtotal()
  calculateTotal()

$(document).on "change", ".purchase-row .line-cost", ->
  $(@).val(formatMoney($(@).val()))
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

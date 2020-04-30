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

addPurchaseRow = (purchaseDetails) ->
  # Add an empty row
  numRows = $(".purchase-row").length
  $("#purchase-table tbody").append tmpl("purchases-new-purchase-template", data.num_rows = numRows)
  return unless purchaseDetails
  # Populate that row if there are purchaseDetails
  row = $("#purchase-table tbody tr:last")
  purchaseDetailId = row.find(".purchase_detail_id")
  category = row.find(".category")
  item = row.find(".item")
  quantity = row.find(".quantity")
  cost = row.find(".cost")
  variance = row.find(".variance")
  itemValue = row.find(".item_value")

  purchaseDetailId.val purchaseDetails.id
  category.val purchaseDetails.category_id
  category.trigger "change"
  item.val purchaseDetails.item_id
  item.trigger "change"
  quantity.val purchaseDetails.quantity
  cost.val formatMoney(purchaseDetails.cost)
  variance.val formatMoney(purchaseDetails.variance)
  itemValue.val purchaseDetails.item_value
  quantity.trigger "change"
  cost.trigger "change"

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
$(document).on "click", ".delete-row", (event) ->
  event.preventDefault()
  $(@).parents("tr:first").remove()
  # Add a balnk row if user deleted the only row
  addPurchaseRow() if $("#purchase-table tbody tr").length == 0

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

addPurchaseDetailRow = (data) ->
  if $(".purchase-detail-row:last").attr('class') != undefined
    lastRowIsOdd = $(".purchase-detail-row:last").attr('class').split(" ").indexOf("odd-row") > 0

  $(".purchase-detail-rows").append(data.content)
  $(".purchase-detail-row:last").removeClass('odd-row').addClass('even-row') if lastRowIsOdd
  $(".purchase-category .select2").select2({ theme: "bootstrap", width: "100%" })
  $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"})

calculateLineCostAndVariance = (activeElement) ->
  purchaseRow = activeElement.parents ".purchase-detail-row"
  quantityElement = purchaseRow.find ".quantity"
  costElement = purchaseRow.find ".cost"
  lineCostElement = purchaseRow.find ".line-cost"
  varianceElement = purchaseRow.find ".price-point-variance"

  itemValue = getCurrentItemValue(purchaseRow)
  lineCost = costElement.val() * quantityElement.val()
  variance = costElement.val() - itemValue

  lineCostElement.val(formatMoney(lineCost))
  varianceElement.html("$" + formatMoney(variance) + " (from $" + formatMoney(itemValue) + ")")

calculateSubtotal = ->
  subtotal = 0

  for element in $(".line-cost")
    if $(element).val() != ""
      subtotal += parseFloat($(element).val())

  return subtotal

calculateTotal = (subtotal) ->
  tax = parseFloat($("#purchase_tax").val())
  shipping = parseFloat($("#purchase_shipping_cost").val())
  return subtotal + tax + shipping

calculateQuantityRemaining = (shipmentTable, purchaseDetail) ->
  shipments = shipmentTable.find(".purchase-shipment-row")
  shipped = 0
  shipments.each((idx, shipment) ->
    quantity = parseInt($(shipment).find(".quantity-received").val())
    shipped = shipped + quantity
  )
  purchaseDetail.quantity_remaining = purchaseDetail.quantity - shipped

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

updateVendorInfo = (selectedVendorId) ->
  vendors = data.vendors
  for vendor in vendors
    if parseInt(vendor.id) == parseInt(selectedVendorId)
      $(".vendor-website").html(vendor.website)
      $(".vendor-phone").html(vendor.phone_number)
      $(".vendor-email").html(vendor.email)
      $(".vendor-contact-name").html(vendor.contact_name)

updateTotals = () ->
  subtotal = calculateSubtotal()
  $(".subtotal").html("$" + formatMoney(subtotal))
  total = calculateTotal(subtotal)
  $(".total").html("$" + formatMoney(total))


######################
# Print the Purhcase #
######################

$(document).on "click", "#print-purchase", (event) ->
  printOrder()

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

$(document).on "change", "#purchase_vendor_id", ->
  if parseInt($(@).val()) > 0
    updateVendorInfo($(@).val())
  else
    $(".vendor-website").html("")
    $(".vendor-phone").html("")
    $(".vendor-email").html("")
    $(".vendor-contact-name").html("")
    $("input#purchase_po").val = ""

####################
# Purchase Details #
####################

$(document).on "page:change", ->
  $(".purchase-category .select2").select2({ theme: "bootstrap", width: "100%" })
  $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"})

$(document).on 'click', '.add-purchase-detail-row', (e) ->
  purchaseId = $(@).data("purchaseId")
  purchaseDetailIndex = $(".purchase-detail-row").length
  data = purchase_id: purchaseId, purchase_detail_index: purchaseDetailIndex

  $.ajax "/purchase_details",
         type: 'POST',
         dataType: 'json',
         data: data
         success: (data) -> addPurchaseDetailRow(data)

$(document).on "click", ".remove-purchase-detail-fields", (event) ->
  event.preventDefault()
  event.target.closest('.purchase-detail-row').remove()

$(document).on "change", "#category", ->
  item_element = $(@).parents(".purchase-detail-row").find(".item")

  if $(@).val() == ""
    item_element.prop('disabled', true)
    item_element.prop("selectedIndex", 0)
    item_element.children('option:first').html("<=- Select a category")
  else
    populateItems($(@).val(), item_element)
    item_element.removeAttr('disabled')

  $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"})

$(document).on "change", ".purchase-detail-row .item", ->
  calculateLineCostAndVariance($(@))

$(document).on "change", ".purchase-detail-row .quantity", ->
  calculateLineCostAndVariance($(@))
  updateTotals()


######################
# Purchase Shipments #
######################

# Toggle the shipments table for a row
$(document).on "click", ".toggle-shipment-table", (event) ->
  event.preventDefault()
  purchaseShipmentRow = $(@).parents(".purchase-detail-row").next()
  purchaseShipmentRow.toggleClass("hidden")

$(document).on 'click', '.add-purchase-shipment-row', (e) ->
  purchaseDetailId = $(@).data("purchaseDetailId")
  purchaseDetailIndex = $(@).data("purchaseDetailIndex")
  table = $(".purchase-shipments-table[data-shipment-table-for='#{purchaseDetailId}']")
  purchaseShipmentIndex = table.find(".purchase-shipment-row").length || 0
  data =
    purchase_detail_id: purchaseDetailId,
    purchase_detail_index: purchaseDetailIndex,
    purchase_shipment_index: purchaseShipmentIndex

  $.ajax "/purchase_shipments",
         type: 'POST',
         dataType: 'json',
         data: data,
         success: (data) ->
           table.find('.purchase-shipment-rows').append(data.content)
           $(".purchase-category .select2").select2({ theme: "bootstrap", width: "100%" })
           $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"})

$(document).on "click", ".remove-purchase-shipment-fields", (event) ->
  event.preventDefault()
  event.target.closest('.purchase-shipment-row').remove()

################
# Calculations #
################

$(document).on "change", ".purchase-detail-row .cost", ->
  $(@).val(formatMoney($(@).val()))
  calculateLineCostAndVariance($(@))
  updateTotals()

$(document).on "change", ".purchase-detail-row .line-cost", ->
  $(@).val(formatMoney($(@).val()))
  purchaseRow = $(@).parents(".purchase-detail-row")
  quantityElement = purchaseRow.find ".quantity"
  costElement = purchaseRow.find ".cost"
  lineCostElement = purchaseRow.find ".line-cost"
  itemValue = getCurrentItemValue(purchaseRow)

  cost = lineCostElement.val() / quantityElement.val()
  variance = cost - itemValue
  costElement.val(formatMoney(cost))
  varianceElement.val(formatMoney(variance) + " (from " + itemValue + ")")
  updateTotals()

$(document).on "change", "#purchase_tax", ->
  tax = $(@).val()
  $(@).val(formatMoney(tax))
  total = calculateTotal(calculateSubtotal())
  $(".total").html("$" + formatMoney(total))

$(document).on "change", "#purchase_shipping_cost", ->
  shipping = $(@).val()
  $(@).val(formatMoney(shipping))
  total = calculateTotal(calculateSubtotal())
  $(".total").html("$" + formatMoney(total))

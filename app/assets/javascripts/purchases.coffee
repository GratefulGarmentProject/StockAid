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
  varianceElement.val(formatMoney(variance) + " (from " + formatMoney(itemValue) + ")")

calcuateSubtotal = ->
  lineCostElements = $(".line-cost")
  subtotal = 0
  for element in lineCostElements
    subtotal += parseFloat($(element).val())

  $(".subtotal").val(formatMoney(subtotal))

calculateTotal = ->
  subTotal = parseFloat($("#subtotal").val())
  tax = parseFloat($("#purchase_tax").val())
  shipping = parseFloat($("#purchase_shipping_cost").val())
  $("#total").val(formatMoney(subTotal + tax + shipping))

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

######################
# Print the Purhcase #
######################

$(document).on "click", "#print-purchase", (event) ->
  printOrder()

#########################
# Return/Enter Escaping #
#########################

$(document).on "keyup keypress", (event) ->
  keyCode = event.keyCode || event.which
  if keyCode == 13
    event.preventDefault()
    return false

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

  calcuateSubtotal()
  calculateTotal()

$(document).on "click", ".add-purchase-detail-fields", (event) ->
  event.preventDefault()
  time = new Date().getTime()
  link = event.target
  rubyObjId = link.dataset.rubyObjId
  regexp = if rubyObjId then new RegExp(rubyObjId, 'g') else null
  newFields = if regexp then link.dataset.fields.replace(regexp, time) else null
  if newFields then $(".purchase-detail-rows").append(newFields) else null

$(document).on "click", ".remove-purchase-detail-fields", (event) ->
  event.preventDefault()
  event.target.closest('.purchase-detail-row').remove()

$(document).on "change", "#category", ->
  item_element = $(@).parents(".purchase-detail-row").find(".item")
  if $(@).val() == undefined
    $(item_element).prop('disabled', true)
  else
    populateItems($(@).val(), item_element)
    $(item_element).removeAttr('disabled')
  $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"})

$(document).on "change", ".purchase-detail-row .item", ->
  calculateLineCostAndVariance($(@))

$(document).on "change", ".purchase-detail-row .quantity", ->
  calculateLineCostAndVariance($(@))
  calcuateSubtotal()
  calculateTotal()


######################
# Purchase Shipments #
######################

# Toggle the shipments table for a row
$(document).on "click", ".toggle-shipment-table", (event) ->
  event.preventDefault()
  purchaseShipmentRow = $(@).parents(".purchase-detail-row").next()
  purchaseShipmentRow.toggleClass("hidden")

$(document).on "click", ".add-purchase-shipment-fields", (event) ->
  event.preventDefault()
  time = new Date().getTime()
  link = event.target
  rubyObjId = link.dataset.rubyObjId
  regexp = if rubyObjId then new RegExp(rubyObjId, 'g') else null
  newFields = if regexp then link.dataset.fields.replace(regexp, time) else null
  if newFields then $(link).parents(".purchase-shipments-table").find(".purchase-shipment-rows").append(newFields) else null

$(document).on "click", ".remove-purchase-shipment-fields", (event) ->
  event.preventDefault()
  event.target.closest('.purchase-shipment-row').remove()

################
# Calculations #
################

$(document).on "change", ".purchase-detail-row .cost", ->
  $(@).val(formatMoney($(@).val()))
  calculateLineCostAndVariance($(@))
  calcuateSubtotal()
  calculateTotal()

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

/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const addPurchaseDetailRow = function(data) {
  let lastRowIsOdd;
  if ($(".purchase-detail-row:last").attr('class') !== undefined) {
    lastRowIsOdd = $(".purchase-detail-row:last").attr('class').split(" ").indexOf("odd-row") > 0;
  }

  $(".purchase-detail-rows").append(data.content);
  if (lastRowIsOdd) { $(".purchase-detail-row:last").removeClass('odd-row').addClass('even-row'); }
  $(".purchase-category .select2").select2({ theme: "bootstrap", width: "100%" });
  return $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"});
};

const calculateLineCostAndVariance = function(activeElement) {
  const purchaseRow = activeElement.parents(".purchase-detail-row");
  const quantityElement = purchaseRow.find(".quantity");
  const costElement = purchaseRow.find(".cost");
  const lineCostElement = purchaseRow.find(".line-cost");
  const varianceElement = purchaseRow.find(".price-point-variance");

  const itemValue = getCurrentItemValue(purchaseRow);
  const lineCost = costElement.val() * quantityElement.val();
  const variance = costElement.val() - itemValue;

  lineCostElement.val(formatMoney(lineCost));
  return varianceElement.html("$" + formatMoney(variance) + " (from $" + formatMoney(itemValue) + ")");
};

const calculateSubtotal = function() {
  let subtotal = 0;

  for (var element of Array.from($(".line-cost"))) {
    if ($(element).val() !== "") {
      subtotal += parseFloat($(element).val());
    }
  }

  return subtotal;
};

const calculateTotal = function(subtotal) {
  const tax = parseFloat($("#purchase_tax").val());
  const shipping = parseFloat($("#purchase_shipping_cost").val());
  return subtotal + tax + shipping;
};

const calculateQuantityRemaining = function(shipmentTable, purchaseDetail) {
  const shipments = shipmentTable.find(".purchase-shipment-row");
  let shipped = 0;
  shipments.each(function(idx, shipment) {
    const quantity = parseInt($(shipment).find(".quantity-received").val());
    return shipped = shipped + quantity;
  });
  return purchaseDetail.quantity_remaining = purchaseDetail.quantity - shipped;
};

var getCurrentItemValue = function(row) {
  const itemElement = row.find(".item");
  const optionSelected = itemElement.find("option:selected");
  const {
    itemValue
  } = optionSelected.data();
  return itemValue;
};

const populateItems = function(category_id, element) {
  let currentCategory;
  const id = parseInt(category_id);
  for (var category of Array.from(embedded.categories())) {
    if (category.id === id) {
      currentCategory = category;
    }
  }
  return element.html(tmpl("purchase-item-options-template", currentCategory));
};

const printOrder = () => window.print();

const updateVendorInfo = function(selectedVendorId) {
  const vendors = embedded.vendors();
  return (() => {
    const result = [];
    for (var vendor of Array.from(vendors)) {
      if (parseInt(vendor.id) === parseInt(selectedVendorId)) {
        $(".vendor-website").html(vendor.website);
        $(".vendor-phone").html(vendor.phone_number);
        $(".vendor-email").html(vendor.email);
        result.push($(".vendor-contact-name").html(vendor.contact_name));
      } else {
        result.push(undefined);
      }
    }
    return result;
  })();
};

const updateTotals = function() {
  const subtotal = calculateSubtotal();
  $(".subtotal").html("$" + formatMoney(subtotal));
  const total = calculateTotal(subtotal);
  return $(".total").html("$" + formatMoney(total));
};


//#####################
// Print the Purhcase #
//#####################

$(document).on("click", "#print-purchase", event => printOrder());

//############################
// Vendor selection and info #
//############################

$(document).on("change", "#purchase_vendor_id", function() {
  if (parseInt($(this).val()) > 0) {
    updateVendorInfo($(this).val());
  } else {
    $(".vendor-website").html("");
    $(".vendor-phone").html("");
    $(".vendor-email").html("");
    $(".vendor-contact-name").html("");
    $("input#purchase_po").val("");
  }
});

//###################
// Purchase Details #
//###################

$(document).on("turbolinks:load", function() {
  $(".purchase-category .select2").select2({ theme: "bootstrap", width: "100%" });
  return $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"});
});

$(document).on('click', '.add-purchase-detail-row', function(e) {
  const purchaseId = $(this).data("purchaseId");
  const purchaseDetailIndex = $(".purchase-detail-row").length;
  const data = {purchase_id: purchaseId, purchase_detail_index: purchaseDetailIndex};

  return $.ajax("/purchase_details", {
         method: 'POST',
         dataType: 'json',
         data,
         success(data) { return addPurchaseDetailRow(data); }
       }
  );
});

$(document).on("click", ".remove-purchase-detail-fields", function(event) {
  event.preventDefault();
  return event.target.closest('.purchase-detail-row').remove();
});

$(document).on("change", "#category", function() {
  const item_element = $(this).parents(".purchase-detail-row").find(".item");

  if ($(this).val() === "") {
    item_element.prop('disabled', true);
    item_element.prop("selectedIndex", 0);
    item_element.children('option:first').html("<=- Select a category");
  } else {
    populateItems($(this).val(), item_element);
    item_element.removeAttr('disabled');
  }

  return $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"});
});

$(document).on("change", ".purchase-detail-row .item", function() {
  return calculateLineCostAndVariance($(this));
});

$(document).on("change", ".purchase-detail-row .quantity", function() {
  calculateLineCostAndVariance($(this));
  return updateTotals();
});


//#####################
// Purchase Shipments #
//#####################

// Toggle the shipments table for a row
$(document).on("click", ".toggle-shipment-table", function(event) {
  event.preventDefault();
  const purchaseShipmentRow = $(this).parents(".purchase-detail-row").next();
  return purchaseShipmentRow.toggleClass("hidden");
});

$(document).on('click', '.add-purchase-shipment-row', function(e) {
  const purchaseDetailId = $(this).data("purchaseDetailId");
  const purchaseDetailIndex = $(this).data("purchaseDetailIndex");
  const table = $(`.purchase-shipments-table[data-shipment-table-for='${purchaseDetailId}']`);
  const purchaseShipmentIndex = table.find(".purchase-shipment-row").length || 0;
  const data = {
    purchase_detail_id: purchaseDetailId,
    purchase_detail_index: purchaseDetailIndex,
    purchase_shipment_index: purchaseShipmentIndex
  };

  return $.ajax("/purchase_shipments", {
         method: 'POST',
         dataType: 'json',
         data,
         success(data) {
           table.find('.purchase-shipment-rows').append(data.content);
           $(".purchase-category .select2").select2({ theme: "bootstrap", width: "100%" });
           return $(".purchase-item .select2").select2({theme: "bootstrap", width: "100%"});
         }
       }
  );
});

$(document).on("click", ".remove-purchase-shipment-fields", function(event) {
  event.preventDefault();
  return event.target.closest('.purchase-shipment-row').remove();
});

//###############
// Calculations #
//###############

$(document).on("change", ".purchase-detail-row .cost", function() {
  $(this).val(formatMoney($(this).val()));
  calculateLineCostAndVariance($(this));
  return updateTotals();
});

$(document).on("change", ".purchase-detail-row .line-cost", function() {
  $(this).val(formatMoney($(this).val()));
  const purchaseRow = $(this).parents(".purchase-detail-row");
  const quantityElement = purchaseRow.find(".quantity");
  const costElement = purchaseRow.find(".cost");
  const lineCostElement = purchaseRow.find(".line-cost");
  const itemValue = getCurrentItemValue(purchaseRow);

  const cost = lineCostElement.val() / quantityElement.val();
  const variance = cost - itemValue;
  costElement.val(formatMoney(cost));
  varianceElement.val(formatMoney(variance) + " (from " + itemValue + ")");
  return updateTotals();
});

$(document).on("change", "#purchase_tax", function() {
  const tax = $(this).val();
  $(this).val(formatMoney(tax));
  const total = calculateTotal(calculateSubtotal());
  return $(".total").html("$" + formatMoney(total));
});

$(document).on("change", "#purchase_shipping_cost", function() {
  const shipping = $(this).val();
  $(this).val(formatMoney(shipping));
  const total = calculateTotal(calculateSubtotal());
  return $(".total").html("$" + formatMoney(total));
});

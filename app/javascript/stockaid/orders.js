/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const order_item_class = function(requested, available) {
  if (requested > available) { return 'danger'; }
};

const populateItems = function(category_id, element) {
  let currentCategory;
  const id = parseInt(category_id);
  for (var category of Array.from(embedded.categories())) {
    if (category.id === id) {
      currentCategory = category;
    }
  }
  return element.html(tmpl("orders-item-options-template", currentCategory));
};

const setQuantityMinMax = function(selected, element) {
  const totalAvailableQuantity = selected.data("available-quantity");
  element.attr("data-guard", "required int");
  element.attr("data-guard-int-min", "1").data("guard-int-min", 1);
  element.attr("data-guard-int-max", totalAvailableQuantity).data("guard-int-max", totalAvailableQuantity);

  return element.val("").clearErrors();
};

const populateQuantityAvailable = (element, quantity) => element.text(quantity);

const updatePlaceholder = (element, text) => element.attr("placeholder", text);

const addOrderRow = function(orderDetails) {
  $("#order-table tbody").append(tmpl("orders-new-order-template", {}));
  if (!orderDetails) { return; }

  const row = $("#order-table tbody tr:last");
  const category = row.find(".category");
  const item = row.find(".item");
  const quantity = row.find(".quantity");

  category.val(orderDetails.category_id);
  category.trigger("change");
  item.val(orderDetails.item_id);
  item.trigger("change");
  return quantity.val(orderDetails.quantity);
};

expose("addOrderRows", () => $(function() {
  let added = false;

  for (var orderDetail of Array.from(data.order.order_details)) {
    if (orderDetail.quantity === 0) { continue; }
    added = true;
    addOrderRow(orderDetail);
  }

  if (!added) { return addOrderRow(); }
}));

expose("loadAvailableQuantities", function() {
  const orderQuantityMap = {};

  if (data.order.in_requested_status) {
    for (var details of Array.from(data.order.order_details)) {
      orderQuantityMap[details.item_id] = details.quantity;
    }
  }

  return Array.from(embedded.categories()).map((category) =>
    (() => {
      const result = [];
      for (var item of Array.from(category.items)) {
        item.available_quantity = item.current_quantity - item.requested_quantity;
        result.push(item.available_quantity += orderQuantityMap[item.id] || 0);
      }
      return result;
    })());
});

const addTrackingRow = function() {
  $("#tracking_details-table tbody").append(tmpl("orders-new-tracking-row-template", {}));
  return $("#tracking_details-table").show();
};

const printOrder = () => window.print();

$(document).on("click", ".add-item", function(event) {
  event.preventDefault();
  event.stopPropagation();
  return $("#add_inventory_modal").modal("show");
});

$(document).on("click", "#add-item-row", function(event) {
  event.preventDefault();
  return addOrderRow();
});

$(document).on("click", ".delete-row", function(event) {
  event.preventDefault();
  $(this).parents("tr:first").remove();
  if ($("#order-table tbody tr").length === 0) { return addOrderRow(); }
});

$(document).on("click", "#print-order", event => printOrder());

$(document).on("click", "#add-tracking-number", function(event) {
  event.preventDefault();
  return addTrackingRow();
});

$(document).on("click", "button.suggested-name", function() {
  return $("#order_ship_to_name").val($(this).text());
});

$(document).on("click", "button.suggested-address", function() {
  return $("#order_ship_to_address").val($(this).text());
});

$(document).on("change", ".order-row .category", function() {
  const item_element = $(this).parents(".order-row").find(".item");
  const quantity_element = $(this).parents(".order-row").find(".quantity");
  const quantity_available_element = $(this).parents(".order-row").find(".quantity-available");

  populateItems($(this).val(), item_element);
  updatePlaceholder(quantity_element, "Select an Item...");
  return populateQuantityAvailable(quantity_available_element, "");
});

$(document).on("change", ".order-row .item", function() {
  const selected = $(this).find('option:selected');
  const quantity_element = $(this).parents(".order-row").find(".quantity");
  const quantity_available_element = $(this).parents(".order-row").find(".quantity-available");
  const totalAvailableQuantity = selected.data("available-quantity");

  setQuantityMinMax(selected, quantity_element);
  updatePlaceholder(quantity_element, "Enter Quantity");
  return populateQuantityAvailable(quantity_available_element, totalAvailableQuantity);
});

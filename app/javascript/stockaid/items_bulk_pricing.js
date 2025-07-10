function toCurrencyValue(value) {
  return `$${value.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")}`;
}

function updateBulkPricingRowAndNewGrandTotal($row, amount, updateInput = true) {
  updateBulkPricingRow($row, amount, updateInput);
  updateNewGrandTotal();
}

function getItemQuantity($row) {
  return parseFloat($row.data("item-quantity"));
}

function getItemValue($row) {
  return parseFloat($row.data("item-value"));
}

function getNewItemValue($row) {
  return parseFloat($row.data("new-item-value"));
}

function updateBulkPricingRow($row, amount, updateInput = true) {
  if (updateInput) {
    $row.find("input.new-value").val(amount.toFixed(2));
  }

  const difference = amount - getItemValue($row);

  if (Math.abs(difference) < 0.0001) {
    // It is effectively 0
    $row.find(".col-difference").text("");
  } else {
    $row.find(".col-difference").text(toCurrencyValue(difference));
  }

  const newTotal = amount * getItemQuantity($row);
  $row.find(".col-new-total").text(toCurrencyValue(newTotal));
  $row.data("new-item-value", amount);
}

function updateNewGrandTotal() {
  let newTotal = 0.0;

  $("#bulk-pricing-table tbody tr").each(function() {
    const $this = $(this);
    const rowNewTotal = getNewItemValue($this) * getItemQuantity($this);
    newTotal += rowNewTotal;
  });

  $("#new-grand-total").text(toCurrencyValue(newTotal));
}

$(document).on("click", "#apply-bulk-pricing-percent", () => {
  const adjustText = $("#adjust_all_percentage").val();

  if (adjustText.trim() === "") {
    alert("Cannot adjust without a value!");
    return;
  }

  let adjustPercent = parseFloat(adjustText);

  if (isNaN(adjustPercent)) {
    alert("Invalid value to adjust with!");
    return;
  }

  adjustPercent = adjustPercent / 100.0

  $("#bulk-pricing-table tbody tr").each(function() {
    const $this = $(this);
    const value = getItemValue($this);
    const quantity = getItemQuantity($this);
    updateBulkPricingRow($this, value * adjustPercent);
  });

  updateNewGrandTotal();
});

$(document).on("click", ".undo-bulk-price", function() {
  const $row = $(this).parents("tr:first");
  updateBulkPricingRowAndNewGrandTotal($row, getItemValue($row));
});

$(document).on("change", "input.new-value", function() {
  const $this = $(this);
  const $row = $this.parents("tr:first");
  const newAmountText = $this.val();

  if (newAmountText.trim() === "") {
    alert("Amounts must be a valid value!");
    updateBulkPricingRowAndNewGrandTotal($row, getItemValue($row), true);
    return;
  }

  const newAmount = parseFloat(newAmountText);

  if (isNaN(newAmount)) {
    alert("Invalid new value!");
    updateBulkPricingRowAndNewGrandTotal($row, getItemValue($row), true);
    return;
  }

  updateBulkPricingRowAndNewGrandTotal($row, newAmount, false);
});

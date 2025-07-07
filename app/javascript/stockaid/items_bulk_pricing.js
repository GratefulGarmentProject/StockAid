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
    const value = $this.data("item-value");
    const quantity = $this.data("item-quantity");
    $this.find("input.new-value").val((value * adjustPercent).toFixed(2));
  });
});

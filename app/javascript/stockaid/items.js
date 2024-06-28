/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const looksLikeMoney = value => /^(-|\+)?[\d,]+(\.?\d{2})?$/.test(value);
const hasInvalidCommas = value => (value.indexOf(",") >= 0) && !/^(-|\+)?\$?[1-9]\d{0,2}(,\d{3})+(\.\d{2})?$/.test(value);

const moneyNoDollar = function(value, options) {
  value = $.trim(value);
  if (value === "") { return true; }
  if (!looksLikeMoney(value)) { return false; }
  if (hasInvalidCommas(value)) { return false; }
  return $.guards.isInRange(parseFloat(value.replace(/,/g, "")), options);
};

const guard = $.guards.name("moneynodollar").using($.guards.aggregate($.guards.isAllValid, moneyNoDollar));

guard.moneyNoDollarErrorElement = function(message) {
  return $(`<${this.getTag()} class="${this.getMessageClass()}"/>`).html(message);
};

guard.moneyNoDollarMessageFn = function(elements) {
  const value = $(elements).val();
  if (value.indexOf("$") >= 0) { return this.moneyNoDollarErrorElement("Please don't include the dollar sign ($)."); }
  if (/\.\d{3,}$/.test(value)) { return this.moneyNoDollarErrorElement("Please round your cents to 2 digits."); }
  if (/\.\d?$/.test(value)) { return this.moneyNoDollarErrorElement("Did you misstype your cents?"); }
  if (!looksLikeMoney(value)) { return this.moneyNoDollarErrorElement("Please enter a valid amount (like <strong>10.50</strong>)."); }
  if (hasInvalidCommas(value)) { return this.moneyNoDollarErrorElement("Please only use commas every 3 digits."); }

  const minMaxOptions = {
    minAndMax: "Please enter an amount from $\#{0} to $\#{1}.",
    min: "Please enter an amount no less than $\#{0}.",
    max: "Please enter an amount no greater than $\#{0}.",
    invalid: "Please enter a dollar amount."
  };

  const messageFn = $.guards.minMaxMessage(minMaxOptions, x => x.toFixed(2));
  const message = messageFn.apply(this, this.getGuardArguments(elements));
  return this.moneyNoDollarErrorElement(message);
};

guard.messageFn(elements => guard.moneyNoDollarMessageFn(elements));

$.guards.name("itembindupes").message("You have duplicate bins selected.").using(function(value) {
  const values = [];
  $(".bin-selector").each(function() {
    return values.push($(this).val());
  });
  let count = 0;

  for (var x of Array.from(values)) {
    if (x === value) { count += 1; }
  }

  return count <= 1;
});

expose("updateProgramPercentages", function() {
  const selectedRatioId = $("#item_item_program_ratio_id").val();
  $(".program-percent-container").hide();
  return (() => {
    const result = [];
    for (var programId in data.itemProgramRatios[selectedRatioId]) {
      var percent = data.itemProgramRatios[selectedRatioId][programId];
      $(`#program-percent-${programId}`).text(percent);
      result.push($(`#program-percent-container-${programId}`).show());
    }
    return result;
  })();
});

$.eachCategory = callback => Array.from(embedded.categories()).map((category) => callback(category));

$.eachInventoryItem = function(category, callback) {
  if (arguments.length === 1) {
    // A call without a category iterates through all items in all categories
    callback = category;
    return $.eachCategory(c => Array.from(c.items).map((item) => callback(item, c)));
  } else {
    return (() => {
      const result = [];
      for (var item of Array.from(category.items)) {         result.push(callback(item, category));
      }
      return result;
    })();
  }
};

$(document).on("change", "#item_item_program_ratio_id", () => updateProgramPercentages());

$(document).on("turbolinks:load", () => $("[data-toggle='tooltip']").tooltip());

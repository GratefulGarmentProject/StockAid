/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$.guards.name("binLocationUnique").grouped().target("#bin-location-error-target").message("Location must be unique.").using(function(values) {
  const rack = values[0];
  const shelf = values[1];
  if ((rack === "") && (shelf === "")) { return true; }

  for (var x of Array.from($("#bin-location-selector option[data-rack][data-shelf]"))) {
    var xRack = $(x).data("rack");
    var xShelf = $(x).data("shelf");
    if ((rack === xRack) && (shelf === xShelf)) { return false; }
  }

  return true;
});

$.guards.name("binitemdupes").message("You have duplicate items selected.").using(function(value) {
  const values = [];
  $(".item-selector").each(function() {
    return values.push($(this).val());
  });
  let count = 0;

  for (var x of Array.from(values)) {
    if (x === value) { count += 1; }
  }

  return count <= 1;
});

$(document).on("change", "#bin-location-selector", function(event) {
  const option = $("option:selected", this);
  const value = option.val();
  $("#existing-bin-location-fields, #new-bin-location-fields").empty();

  switch (value) {
    case "": // Do nothing
    case "new":
      var content = tmpl("new-bin-location-template", {});
      return $("#new-bin-location-fields").html(content).show();
    default:
      content = tmpl("existing-bin-location-template", option.data());
      return $("#existing-bin-location-fields").html(content).show();
  }
});

expose("initializeBinLocations", function() {
  const defaultMatcher = $.fn.select2.defaults.defaults.matcher;

  return $(() => $("#bin-location-selector").select2({
    theme: "bootstrap",
    width: "100%",
    matcher(params, data) {
      const textToMatch = data.element.getAttribute("data-search-text") || "";

      if (defaultMatcher(params, { text: textToMatch })) {
        return data;
      } else {
        return null;
      }
    }
  }));
});

expose("eachBin", callback => Array.from(data.bins).map((bin) => callback(bin)));

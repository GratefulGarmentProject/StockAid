/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
expose("initializeVendors", function() {
  const defaultMatcher = $.fn.select2.defaults.defaults.matcher;

  return $(() => $("#vendor-selector, .vendor-selector").select2({
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

$(document).on("turbolinks:load", () => {
  const defaultMatcher = $.fn.select2.defaults.defaults.matcher;

  $("select.select2").select2({ theme: "bootstrap", width: "100%" })

  $("select.select2-with-customized-search-text").select2({
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
  });
});

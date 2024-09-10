$(document).on("turbolinks:load", () => {
  const defaultMatcher = $.fn.select2.defaults.defaults.matcher;

  $("select.select2").each(function(i, e) {
    const $element = $(e);
    let width = "100%";

    if ($element.data("select2-width")) {
      width = $element.data("select2-width");
    }

    $(e).select2({ theme: "bootstrap", width: width });
  });

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

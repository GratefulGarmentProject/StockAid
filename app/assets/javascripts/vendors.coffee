expose "initializeVendors", ->
  defaultMatcher = $.fn.select2.defaults.defaults.matcher

  $ ->
    $("#vendor-selector, .vendor-selector").select2
      theme: "bootstrap"
      width: "100%"
      matcher: (params, data) ->
        textToMatch = data.element.getAttribute("data-search-text") || ""

        if defaultMatcher(params, { text: textToMatch })
          data
        else
          null

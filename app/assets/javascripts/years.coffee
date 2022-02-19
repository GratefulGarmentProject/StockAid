expose "initializeYears", ->
  defaultMatcher = $.fn.select2.defaults.defaults.matcher

  $ ->
    $("#year-selector, .year-selector").select2
      theme: "bootstrap"
      width: "100%"
      matcher: (params, data) ->
        textToMatch = data.element.getAttribute("data-search-text") || ""

        if defaultMatcher(params, { text: textToMatch })
          data
        else
          null

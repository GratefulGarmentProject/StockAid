$(document).on "click", ".js-select-all", (ev) ->
  $("input:checkbox").prop("checked", true)

$(document).on "click", ".js-select-none", (ev) ->
  $("input:checkbox").prop("checked", false)

$(document).on "click", ".check-all", (e) ->
  e.preventDefault()
  e.stopPropagation()

  selector = $(@).data("check-all-target")
  $(selector).find(":checkbox").prop("checked", true);

$(document).on "click", ".uncheck-all", (e) ->
  e.preventDefault()
  e.stopPropagation()

  selector = $(@).data("uncheck-all-target")
  $(selector).find(":checkbox").prop("checked", false);

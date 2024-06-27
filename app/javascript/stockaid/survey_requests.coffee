$(document).on "change", ":checkbox.selected-survey-request-organization-checkbox", (e) ->
  label = $(".amount-survey-request-organizations-checked")
  amount = $(":checkbox.selected-survey-request-organization-checkbox:checked").size()
  label.text("(#{amount} checked)")

  if amount > 0
    label.addClass("text-bold")
  else
    label.removeClass("text-bold")

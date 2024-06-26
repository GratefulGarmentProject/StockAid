$(document).on "change", ".auto-submit", (e) ->
  $(e.target).closest("form").submit()

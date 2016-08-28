window.addAddressRow = ->
  $("#organization_info").append tmpl("organizations-new-address-template", {})

$(document).on "click", "#add-new-address", (event) ->
  event.preventDefault()
  addAddressRow()

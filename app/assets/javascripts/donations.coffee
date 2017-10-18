# Once we can edit donations, this should behave like addOrderRow from orders.coffee
addDonationRow = ->
  row = $ tmpl("donation-row-template", {})
  $("#donation-table tbody").append row
  row.find("select").select2(theme: "bootstrap")

expose "addInitialDonationRow", ->
  $ ->
    # Once we can edit donations, this should behave like addOrderRows from orders.coffee
    addDonationRow()

$(document).on "click", "#add-donation-row", (event) ->
  event.preventDefault()
  addDonationRow()

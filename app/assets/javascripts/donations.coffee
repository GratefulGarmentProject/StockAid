# Once we can edit donations, this should behave like addOrderRow from orders.coffee
addDonationRow = ->
  row = $ tmpl("item-selector-template", name: "item_id[]")
  $("#donation-rows").append row
  row.find("select").select2(theme: "bootstrap")

expose "addDonationRows", ->
  $ ->
    # Once we can edit donations, this should behave like addOrderRows from orders.coffee
    addDonationRow()

$(document).on "click", "#add-donation-row", (event) ->
  event.preventDefault()
  addDonationRow()

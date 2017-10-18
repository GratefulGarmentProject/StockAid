addDonationRow = ->
  row = $ tmpl("donation-row-template", {})
  $("#donation-table tbody").append row
  row.find("select").select2(theme: "bootstrap")

expose "addInitialDonationRow", ->
  $ ->
    addDonationRow()

$(document).on "click", "#add-donation-row", (event) ->
  event.preventDefault()
  addDonationRow()

buildDonationTypeahead = (names) ->
  donatorsBloodhound = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: names
  })

  donatorsBloodhound.initialize()

  $('.typeahead').typeahead(null, {
    displayKey: 'name',
    source: donatorsBloodhound.ttAdapter()
  })

expose "makeDonationTypeahead", (names) ->
  $ ->
    buildDonationTypeahead(names)

window.addAddressRow = ->
  count = $("[id^='organization_addresses_attributes']:text").length
  newRow = $ """
  <div class="form-group">
    <label for="organization_addresses_attributes_#{count}_address">Mailing Address</label>

      <input class="form-control" data-guard="different" type="text" value="" name="organization[addresses_attributes][#{count}][address]" id="organization_addresses_attributes_#{count}_address">
  </div>
  """

  $("#organization_info").append newRow

$(document).on "click", "#add-new-address", (event) ->
  event.preventDefault()
  addAddressRow()

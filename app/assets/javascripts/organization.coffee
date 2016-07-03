window.addAddressRow = (count) ->
  newRow = $ """
  <div class="form-group">
    <label for="organization_addresses_attributes_""" + count + """_address">Mailing Address</label>

    <div>
      <input class="form-control" data-guard="different" type="text" value="" name="organization[addresses_attributes][""" + count + """][address]" id="organization_addresses_attributes_""" + count + """_address">
    </div>
  </div>

  <input type="hidden" value="" name="organization[addresses_attributes][""" + count + """][id]" id="organization_addresses_attributes_""" + count + """_id">
  """

  $("#organization_edit").append newRow

$(document).on "click", "#add-new-address", (event) ->
  event.preventDefault()
  count = $("[id^='organization_addresses_attributes']:text").length
  addAddressRow(count)

# $(document).on "click", ".delete-row", (event) ->
#   event.preventDefault()
#   $(@).parents("tr:first").remove()
#   addOrderRow() if $("#order-table tbody tr").length == 0


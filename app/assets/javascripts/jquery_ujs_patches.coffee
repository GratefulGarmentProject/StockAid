# This fixes Rails auto disabling to not disable when there is an error on the form.
if $.rails && $.rails.disableFormElement
  originalDisableFormElement = $.rails.disableFormElement
  $.rails.disableFormElement = (element) ->
    return if $(element).parent("form").find(":guardable:has-error").size() > 0
    originalDisableFormElement(element)
else
  console.warn("Could not find $.rails.disableFormElement to patch!")

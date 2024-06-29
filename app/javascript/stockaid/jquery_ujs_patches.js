/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
// This fixes Rails auto disabling to not disable when there is an error on the form.
if ($.rails && $.rails.disableFormElement) {
  const originalDisableFormElement = $.rails.disableFormElement;
  $.rails.disableFormElement = function(element) {
    if ($(element).parents("form:first").find(":guardable:has-error").length > 0) { return; }
    return originalDisableFormElement(element);
  };
} else {
  console.warn("Could not find $.rails.disableFormElement to patch!");
}

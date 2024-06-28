/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
expose("initializeExternalTypeSelector", () => $(document).ready(() => $("#external-type").select2({
  placeholder: "Select a type",
  theme: "bootstrap",
  width: "100%"
})));

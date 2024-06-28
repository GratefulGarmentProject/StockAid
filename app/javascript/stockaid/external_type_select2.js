$(document).on("turbolinks:load", () => {
  $("#external-type").select2({
    placeholder: "Select a type",
    theme: "bootstrap",
    width: "100%"
  });
});

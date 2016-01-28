$(document).on "click", "button[data-create-item]", ->
  $element = $(@)
  $("#category").val $element.data("category")
  $("#addItem").find(".category-label").text $element.data("category-desc")
  $("#addItem").modal("show")

$(document).on "shown.bs.modal", "#addItem", ->
  $("#description").focus()

$(document).on "page:load", ->
  # modal submits
  $("#submitItem").on "click", ->
    $("#itemForm").submit()
  $("#submitCategory").on "click", ->
    $("#categoryForm").submit()

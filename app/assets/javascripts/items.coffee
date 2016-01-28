setEvents = () ->
  $("#submitItem").on "click", ->
    $("#itemForm").submit()

  $("#submitCategory").on "click", ->
    $("#categoryForm").submit()

$ ->
  setEvents()

# For turbo-links
$(document).on "page:load", ->
  setEvents()


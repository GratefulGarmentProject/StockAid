$ ->
  $("#submitItem").on "click", ->
    $("#itemForm").submit()

$(document).on "page:load", ->
  $(".item-link").on "click", ->
    window.location = $(this).data('url')

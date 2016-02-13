$(document).on "page:load", ->
  return unless $("body.users.index").length > 0

  $('.data-table').DataTable()

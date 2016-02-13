$(document).on "page:load", ->
  return unless $("body.organizations.index").length > 0

  $('.data-table').DataTable()

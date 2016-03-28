$(document).on "page:change", ->
  $(".data-table").DataTable
    "responsive": true
    "order": [[ 0, "desc" ]]


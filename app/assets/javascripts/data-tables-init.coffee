$(document).on "page:change", ->
  $(".data-table").DataTable
    "order": [[ 0, "desc" ]]


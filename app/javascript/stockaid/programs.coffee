$(document).on "turbolinks:load", ->
  $("select.program").select2({ theme: "bootstrap", width: "100%" })

$(document).on "turbolinks:load", ->
  $("select.program-survey").select2({ theme: "bootstrap", width: "100%" })

expose "initializeExternalTypeSelector", ->
  $(document).ready ->
    $("#external-type").select2
      placeholder: "Select a type"
      theme: "bootstrap"
      width: "100%"

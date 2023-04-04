surveyFields = []
nextId = 1

$(document).on "click", "#add-survey-field", (e) ->
  content = tmpl("survey-field-template", { fields: surveyFields, id: nextId++ })
  $("#survey-fields").append(content)

expose "initializeSurveys", (data) ->
  surveyFields = data.fields

surveyFieldTypes = []
nextId = 1
surveyFields = {}

class SurveyField
  constructor: ->
    @id = nextId++
    @type = ""
    @content = $(tmpl("survey-field-template", { fieldTypes: surveyFieldTypes, field: this }))
    $("#survey-fields").append(@content)

  remove: () ->
    @content.remove()

  setType: (value) ->
    if @type == value
      return

    @type = value
    typeContainer = @content.find(".survey-field-type-container").empty()

    if @type != ""
      typeContainer.html(tmpl("survey-edit-#{@type}-template", { field: this }))

    if @type == "select"
      @addOption()

  addOption: ->
    optionsContainer = @content.find(".survey-select-options")
    optionsContainer.append(tmpl("survey-edit-select-option-template", { field: this }))

  removeOption: ($btn) ->
    $btn.parents(".survey-select-option-container:first").remove()

$(document).on "click", "#add-survey-field", ->
  field = new SurveyField()
  surveyFields[field.id] = field

$(document).on "click", ".remove-survey-field", ->
  $this = $(this)
  id = $this.parents(".survey-field-container:first").data("survey-field-id")
  surveyFields[id].remove()
  delete surveyFields[id]

$(document).on "change", "select.survey-field-type", ->
  $this = $(this)
  id = $this.parents(".survey-field-container:first").data("survey-field-id")
  surveyFields[id].setType($this.val())

$(document).on "click", ".add-survey-select-option", ->
  $this = $(this)
  id = $this.parents(".survey-field-container:first").data("survey-field-id")
  surveyFields[id].addOption()

$(document).on "click", ".remove-survey-select-option", ->
  $this = $(this)
  id = $this.parents(".survey-field-container:first").data("survey-field-id")
  surveyFields[id].removeOption($this)

expose "initializeSurveys", (data) ->
  surveyFieldTypes = data.fields
  surveyFields = {}
  window.SURVEY_FIELDS = surveyFields

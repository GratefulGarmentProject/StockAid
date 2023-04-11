surveyFieldTypes = []
nextId = 1
surveyFields = {}

class SurveyField
  constructor: (parent, container, scope) ->
    @parent = parent
    @id = nextId++
    @type = ""
    @scope = scope
    @content = $(tmpl("survey-field-template", { fieldTypes: surveyFieldTypes, field: this }))
    @groupedFields = []
    container.append(@content)

  getFieldScope: ->
    "#{@scope}[field-#{@id}]"

  remove: ->
    @removeChildFields()
    @content.remove()
    delete surveyFields[@id]

    if @parent
      @parent.removeGroupedField(this)

  removeChildFields: ->
    fields = @groupedFields
    @groupedFields = []
    field.remove() for field in fields

  removeGroupedField: (field) ->
    index = @groupedFields.indexOf(field)

    if index >= 0
      @groupedFields.splice(index, 1)

  setType: (value) ->
    if @type == value
      return

    @removeChildFields()
    @type = value
    typeContainer = @content.find(".survey-field-type-container:first").empty()

    if @type != ""
      typeContainer.html(tmpl("survey-edit-#{@type}-template", { field: this }))

    if @type == "select"
      @addOption()

  addOption: ->
    optionsContainer = @content.find(".survey-select-options:first")
    optionsContainer.append(tmpl("survey-edit-select-option-template", { field: this }))

  removeOption: ($btn) ->
    $btn.parents(".survey-select-option-container:first").remove()

  addGroupedField: ->
    field = new SurveyField(this, @content.find(".survey-grouped-fields-container:first"), "#{@getFieldScope()}[fields]")
    surveyFields[field.id] = field
    @groupedFields.push(field)

$(document).on "click", "#add-survey-field", ->
  field = new SurveyField(null, $("#survey-fields"), "fields")
  surveyFields[field.id] = field

$(document).on "click", ".add-grouped-survey-field", ->
  $this = $(this)
  id = $this.parents(".survey-field-container:first").data("survey-field-id")
  surveyFields[id].addGroupedField()

$(document).on "click", ".remove-survey-field", ->
  $this = $(this)
  id = $this.parents(".survey-field-container:first").data("survey-field-id")
  surveyFields[id].remove()

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

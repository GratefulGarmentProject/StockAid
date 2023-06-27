surveyFieldTypes = []
nextId = 1
surveyFields = {}

class SurveyField
  constructor: (parent, container, scope, data = null) ->
    @parent = parent
    @id = nextId++
    @type = ""
    @scope = scope
    @data = data
    @content = $(tmpl("survey-field-template", { fieldTypes: surveyFieldTypes, field: this }))
    @groupedFields = []
    container.append(@content)

    if data
      @content.find("select.survey-field-type").val(data.type)
      @setType(data.type, true)

      if @type == "select" && @data.options
        @addOption(option) for option in @data.options

  getDataValue: (key) ->
    if @data
      @data[key]

  getInitiallyRequiredCheckedState: ->
    if @data
      if @data.required
        "checked"
    else
      "checked"

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

  setType: (value, existing = false) ->
    if @type == value
      return

    @removeChildFields()
    @type = value
    typeContainer = @content.find(".survey-field-type-container:first").empty()

    if @type != ""
      typeContainer.html(tmpl("survey-edit-#{@type}-template", { field: this }))

    if !existing && @type == "select"
      @addOption()

  addOption: (value = "") ->
    optionsContainer = @content.find(".survey-select-options:first")
    optionsContainer.append(tmpl("survey-edit-select-option-template", { field: this, value: value }))

  removeOption: ($btn) ->
    $btn.parents(".survey-select-option-container:first").remove()

  addGroupedField: (data = null) ->
    field = new SurveyField(this, @content.find(".survey-grouped-fields-container:first"), "#{@getFieldScope()}[fields]", data)
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
  surveyFields[id].addOption().find("input[type='text']").focus()

$(document).on "click", ".remove-survey-select-option", ->
  $this = $(this)
  id = $this.parents(".survey-field-container:first").data("survey-field-id")
  surveyFields[id].removeOption($this)

changedRevisionNameGuard = $.guard("#revision-title").using("never").message("You must change this for a new revision.")
$(document).on "click", "#save-new-revision", (e) ->
  if $("#revision-title").val() == $("#original-revision-title").val()
    changedRevisionNameGuard.triggerError("#revision-title")
    e.preventDefault()
    $("#revision-title").focus()

addExistingField = (fieldData) ->
  field = new SurveyField(null, $("#survey-fields"), "fields", fieldData)
  surveyFields[field.id] = field

  if fieldData.type == "group"
    field.addGroupedField(childFieldData) for childFieldData in fieldData.fields

expose "initializeSurveys", (globalData, surveyData) ->
  surveyFieldTypes = globalData.fields
  surveyFields = {}

  if surveyData
    addExistingField(fieldData) for fieldData in surveyData.fields

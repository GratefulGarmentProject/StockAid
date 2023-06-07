nextId = 1
surveyFields = {}

class SurveyAnswerField
  constructor: (parent, container, scope, data, answerData, answerIndex) ->
    @parent = parent
    @id = nextId++
    @scope = scope
    @data = data
    @answerData = answerData
    @answerIndex = answerIndex
    @content = $($.parseHTML(tmpl("survey-answer-#{data.type}-template", { field: this }), document))
    container.append(@content)

    if @data.type == "group"
      @grouped = true
      @childAnswers = 0
      @childFields = []
      @groups = {}

      for childAnswerData, i in @answerData
        @addGroupedAnswer(childAnswerData)

  addGroupedAnswer: (answerData) ->
    @childAnswers++
    groupId = nextId++
    answerWellId = "survey-grouped-answer-fields-group-#{groupId}-container"
    answerWell = $("""<div class="well" id="#{answerWellId}"></div>""")
    groupedAnswersContainer = $("#survey-grouped-answer-fields-container-#{@id}")
    groupedAnswersContainer.append(answerWell)
    @groups[groupId] = []

    for fieldData, i in @data.fields
      field = new SurveyAnswerField(this, answerWell, "#{@scope}[#{@answerIndex}][group_#{groupId}]", fieldData, answerData[i], i)
      surveyFields[field.id] = field
      @groups[groupId].push(field)
      @childFields.push(field)

    answerWell.append("""<button type="button" data-parent-field-id="#{@id}" data-group-id="#{groupId}" class="remove-grouped-survey-answers remove-grouped-survey-answers-#{@id} btn btn-danger">Remove</button>""")
    @updateAddRemoveButtonDisabled()

  updateAddRemoveButtonDisabled: ->
    groupedAnswersContainer = $("#survey-grouped-answer-fields-container-#{@id}")

    if @data.min && @childAnswers <= @data.min
      groupedAnswersContainer.find(".remove-grouped-survey-answers-#{@id}").prop("disabled", true)
    else
      groupedAnswersContainer.find(".remove-grouped-survey-answers-#{@id}").prop("disabled", false)

    if @data.max && @childAnswers >= @data.max
      @content.find(".add-grouped-survey-answers-#{@id}").prop("disabled", true)
    else
      @content.find(".add-grouped-survey-answers-#{@id}").prop("disabled", false)

  removeGroup: (groupId) ->
    for field in @groups[groupId]
      field.remove()

    $("#survey-grouped-answer-fields-group-#{groupId}-container").remove()
    delete @groups[groupId]
    @childAnswers--
    @updateAddRemoveButtonDisabled()

  remove: ->
    if @grouped
      for field in @childFields
        field.remove()

    @content.remove()
    delete surveyFields[@id]

  getAddGroupButtonDataAttributes: ->
    result = ["data-field-id=\"#{@id}\""]

    unless isNullOrUndefined(@data.min)
      result.push("data-min=\"#{@data.min}\"")

    unless isNullOrUndefined(@data.max)
      result.push("data-max=\"#{@data.max}\"")

    result.join(" ")

  getFieldName: ->
    "#{@scope}[#{@answerIndex}]"

  getLabel: ->
    @data.label

  getOptions: ->
    @data.options

  isOptionSelected: (index) ->
    if index == null && isNullOrUndefined(@getAnswer())
      return true

    @getAnswer() == index

  getOptionSelected: (index) ->
    "selected" if @isOptionSelected(index)

  getAnswer: ->
    @answerData

  getGuardAttributes: ->
    result = []

    if @data.type == "integer"
      unless isNullOrUndefined(@data.min)
        result.push("data-guard-int-min=\"#{@data.min}\"")

      unless isNullOrUndefined(@data.max)
        result.push("data-guard-int-max=\"#{@data.max}\"")

    result.join(" ")

  getGuards: ->
    result = []

    if @data.required
      result.push("required")

    if @data.type == "integer"
      result.push("int")

    result.join(" ")

addField = (fieldsContainerId, scope, fieldData, answerData, answerIndex) ->
  field = new SurveyAnswerField(null, $("##{fieldsContainerId}"), scope, fieldData, answerData, answerIndex)
  surveyFields[field.id] = field

expose "initializeSurveyAnswers", (fieldsContainerId, scope, surveyData, answerData) ->
  surveyFields = {}

  for fieldData, i in surveyData.fields
    addField(fieldsContainerId, "#{scope}[answers]", fieldData, answerData[i], i)

$(document).on "click", ".add-grouped-survey-answers", (e) ->
  e.preventDefault()
  $btn = $(@)
  fieldId = $btn.data("field-id")
  field = surveyFields[fieldId]
  field.addGroupedAnswer(field.data.blank)

$(document).on "click", ".remove-grouped-survey-answers", (e) ->
  e.preventDefault()
  $btn = $(@)
  fieldId = $btn.data("parent-field-id")
  groupId = $btn.data("group-id")
  surveyFields[fieldId].removeGroup(groupId)

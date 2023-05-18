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
      @childAnswers = 0

      for childAnswerData, i in @answerData
        @addGroupedAnswer(childAnswerData)

  addGroupedAnswer: (answerData) ->
    @childAnswers++
    groupId = nextId++
    answerWellId = "survey-grouped-answer-fields-group-#{groupId}-container"
    answerWell = $("""<div class="well" id="#{answerWellId}"></div>""")
    groupedAnswersContainer = $("#survey-grouped-answer-fields-container-#{@id}")
    groupedAnswersContainer.append(answerWell)

    for fieldData, i in @data.fields
      field = new SurveyAnswerField(this, answerWell, "#{@scope}[#{@answerIndex}][group_#{groupId}]", fieldData, answerData[i], i)
      surveyFields[field.id] = field

    answerWell.append("""<button class="remove-grouped-survey-answers btn btn-danger">Remove</button>""")

    if @data.min && @childAnswers.size <= @data.min
      groupedAnswersContainer.find(".remove-grouped-survey-answers").prop("disabled", true)
    else
      groupedAnswersContainer.find(".remove-grouped-survey-answers").prop("disabled", true)

    if @data.max && @childAnswers.size >= @data.max
      @content.find(".add-grouped-survey-answers").prop("disabled", true)
    else
      @content.find(".add-grouped-survey-answers").prop("disabled", false)

  getAddGroupButtonDataAttributes: ->
    result = ["data-field-id=\"{%= @id %}\""]

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

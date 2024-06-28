/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let nextId = 1;
let surveyFields = {};

class SurveyAnswerField {
  constructor(parent, container, scope, data, answerData, answerIndex) {
    this.parent = parent;
    this.id = nextId++;
    this.scope = scope;
    this.data = data;
    this.answerData = answerData;
    this.answerIndex = answerIndex;
    this.content = $($.parseHTML(tmpl(`survey-answer-${data.type}-template`, { field: this }), document));
    container.append(this.content);

    if (this.data.type === "group") {
      this.grouped = true;
      this.childAnswers = 0;
      this.childFields = [];
      this.groups = {};

      for (let i = 0; i < this.answerData.length; i++) {
        var childAnswerData = this.answerData[i];
        this.addGroupedAnswer(childAnswerData);
      }
    }
  }

  addGroupedAnswer(answerData) {
    this.childAnswers++;
    const groupId = nextId++;
    const answerWellId = `survey-grouped-answer-fields-group-${groupId}-container`;
    const answerWell = $(`<div class="well" id="${answerWellId}"></div>`);
    const groupedAnswersContainer = $(`#survey-grouped-answer-fields-container-${this.id}`);
    groupedAnswersContainer.append(answerWell);
    this.groups[groupId] = [];

    for (let i = 0; i < this.data.fields.length; i++) {
      var fieldData = this.data.fields[i];
      var field = new SurveyAnswerField(this, answerWell, `${this.scope}[${this.answerIndex}][group_${groupId}]`, fieldData, answerData[i], i);
      surveyFields[field.id] = field;
      this.groups[groupId].push(field);
      this.childFields.push(field);
    }

    answerWell.append(`<button type="button" data-parent-field-id="${this.id}" data-group-id="${groupId}" class="remove-grouped-survey-answers remove-grouped-survey-answers-${this.id} btn btn-danger">Remove</button>`);
    return this.updateAddRemoveButtonDisabled();
  }

  updateAddRemoveButtonDisabled() {
    const groupedAnswersContainer = $(`#survey-grouped-answer-fields-container-${this.id}`);

    if (this.data.min && (this.childAnswers <= this.data.min)) {
      groupedAnswersContainer.find(`.remove-grouped-survey-answers-${this.id}`).prop("disabled", true);
    } else {
      groupedAnswersContainer.find(`.remove-grouped-survey-answers-${this.id}`).prop("disabled", false);
    }

    if (this.data.max && (this.childAnswers >= this.data.max)) {
      return this.content.find(`.add-grouped-survey-answers-${this.id}`).prop("disabled", true);
    } else {
      return this.content.find(`.add-grouped-survey-answers-${this.id}`).prop("disabled", false);
    }
  }

  removeGroup(groupId) {
    for (var field of Array.from(this.groups[groupId])) {
      field.remove();
    }

    $(`#survey-grouped-answer-fields-group-${groupId}-container`).remove();
    delete this.groups[groupId];
    this.childAnswers--;
    return this.updateAddRemoveButtonDisabled();
  }

  remove() {
    if (this.grouped) {
      for (var field of Array.from(this.childFields)) {
        field.remove();
      }
    }

    this.content.remove();
    return delete surveyFields[this.id];
  }

  getAddGroupButtonDataAttributes() {
    const result = [`data-field-id=\"${this.id}\"`];

    if (!isNullOrUndefined(this.data.min)) {
      result.push(`data-min=\"${this.data.min}\"`);
    }

    if (!isNullOrUndefined(this.data.max)) {
      result.push(`data-max=\"${this.data.max}\"`);
    }

    return result.join(" ");
  }

  getFieldName() {
    return `${this.scope}[${this.answerIndex}]`;
  }

  getLabel() {
    return this.data.label;
  }

  getOptions() {
    return this.data.options;
  }

  isOptionSelected(index) {
    if ((index === null) && isNullOrUndefined(this.getAnswer())) {
      return true;
    }

    return this.getAnswer() === index;
  }

  getOptionSelected(index) {
    if (this.isOptionSelected(index)) { return "selected"; }
  }

  getAnswer() {
    return this.answerData;
  }

  getGuardAttributes() {
    const result = [];

    if (this.data.type === "integer") {
      if (!isNullOrUndefined(this.data.min)) {
        result.push(`data-guard-int-min=\"${this.data.min}\"`);
      }

      if (!isNullOrUndefined(this.data.max)) {
        result.push(`data-guard-int-max=\"${this.data.max}\"`);
      }
    }

    return result.join(" ");
  }

  getGuards() {
    const result = [];

    if (this.data.required) {
      result.push("required");
    }

    if (this.data.type === "integer") {
      result.push("int");
    }

    return result.join(" ");
  }
}

const addField = function(fieldsContainerId, scope, fieldData, answerData, answerIndex) {
  const field = new SurveyAnswerField(null, $(`#${fieldsContainerId}`), scope, fieldData, answerData, answerIndex);
  return surveyFields[field.id] = field;
};

$(document).on("turbolinks:load", () => {
  if ($("#data-survey-answers-answer-data").length > 0) {
    const fieldsContainerId = embedded.surveyAnswersFieldContainerId();
    const scope = embedded.surveyAnswersScope();
    const surveyData = embedded.surveyAnswersSurveyData();
    const answerData = embedded.surveyAnswersAnswerData();

    surveyFields = {};
    Array.from(surveyData.fields).map((fieldData, i) => addField(fieldsContainerId, `${scope}[answers]`, fieldData, answerData[i], i));
  }
});

$(document).on("click", ".add-grouped-survey-answers", function(e) {
  e.preventDefault();
  const $btn = $(this);
  const fieldId = $btn.data("field-id");
  const field = surveyFields[fieldId];
  return field.addGroupedAnswer(field.data.blank);
});

$(document).on("click", ".remove-grouped-survey-answers", function(e) {
  e.preventDefault();
  const $btn = $(this);
  const fieldId = $btn.data("parent-field-id");
  const groupId = $btn.data("group-id");
  return surveyFields[fieldId].removeGroup(groupId);
});

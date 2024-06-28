/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let surveyFieldTypes = [];
let nextId = 1;
let surveyFields = {};

class SurveyField {
  constructor(parent, container, scope, data = null) {
    this.parent = parent;
    this.id = nextId++;
    this.type = "";
    this.scope = scope;
    this.data = data;
    this.content = $(tmpl("survey-field-template", { fieldTypes: surveyFieldTypes, field: this }));
    this.groupedFields = [];
    container.append(this.content);

    if (data) {
      this.content.find("select.survey-field-type").val(data.type);
      this.setType(data.type, true);

      if ((this.type === "select") && this.data.options) {
        for (var option of Array.from(this.data.options)) { this.addOption(option); }
      }
    }
  }

  getDataValue(key) {
    if (this.data) {
      return this.data[key];
    }
  }

  getInitiallyRequiredCheckedState() {
    if (this.data) {
      if (this.data.required) {
        return "checked";
      }
    } else {
      return "checked";
    }
  }

  getFieldScope() {
    return `${this.scope}[field-${this.id}]`;
  }

  remove() {
    this.removeChildFields();
    this.content.remove();
    delete surveyFields[this.id];

    if (this.parent) {
      return this.parent.removeGroupedField(this);
    }
  }

  removeChildFields() {
    const fields = this.groupedFields;
    this.groupedFields = [];
    return Array.from(fields).map((field) => field.remove());
  }

  removeGroupedField(field) {
    const index = this.groupedFields.indexOf(field);

    if (index >= 0) {
      return this.groupedFields.splice(index, 1);
    }
  }

  setType(value, existing) {
    if (existing == null) { existing = false; }
    if (this.type === value) {
      return;
    }

    this.removeChildFields();
    this.type = value;
    const typeContainer = this.content.find(".survey-field-type-container:first").empty();

    if (this.type !== "") {
      typeContainer.html(tmpl(`survey-edit-${this.type}-template`, { field: this }));
    }

    if (!existing && (this.type === "select")) {
      return this.addOption();
    }
  }

  addOption(value) {
    if (value == null) { value = ""; }
    const optionsContainer = this.content.find(".survey-select-options:first");
    return optionsContainer.append(tmpl("survey-edit-select-option-template", { field: this, value }));
  }

  removeOption($btn) {
    return $btn.parents(".survey-select-option-container:first").remove();
  }

  addGroupedField(data = null) {
    const field = new SurveyField(this, this.content.find(".survey-grouped-fields-container:first"), `${this.getFieldScope()}[fields]`, data);
    surveyFields[field.id] = field;
    return this.groupedFields.push(field);
  }
}

$(document).on("click", "#add-survey-field", function() {
  const field = new SurveyField(null, $("#survey-fields"), "fields");
  return surveyFields[field.id] = field;
});

$(document).on("click", ".add-grouped-survey-field", function() {
  const $this = $(this);
  const id = $this.parents(".survey-field-container:first").data("survey-field-id");
  return surveyFields[id].addGroupedField();
});

$(document).on("click", ".remove-survey-field", function() {
  const $this = $(this);
  const id = $this.parents(".survey-field-container:first").data("survey-field-id");
  return surveyFields[id].remove();
});

$(document).on("change", "select.survey-field-type", function() {
  const $this = $(this);
  const id = $this.parents(".survey-field-container:first").data("survey-field-id");
  return surveyFields[id].setType($this.val());
});

$(document).on("click", ".add-survey-select-option", function() {
  const $this = $(this);
  const id = $this.parents(".survey-field-container:first").data("survey-field-id");
  return surveyFields[id].addOption().find("input[type='text']").focus();
});

$(document).on("click", ".remove-survey-select-option", function() {
  const $this = $(this);
  const id = $this.parents(".survey-field-container:first").data("survey-field-id");
  return surveyFields[id].removeOption($this);
});

const changedRevisionNameGuard = $.guard("#revision-title").using("never").message("You must change this for a new revision.");
$(document).on("click", "#save-new-revision", function(e) {
  if ($("#revision-title").val() === $("#original-revision-title").val()) {
    changedRevisionNameGuard.triggerError("#revision-title");
    e.preventDefault();
    return $("#revision-title").focus();
  }
});

const addExistingField = function(fieldData) {
  const field = new SurveyField(null, $("#survey-fields"), "fields", fieldData);
  surveyFields[field.id] = field;

  if (fieldData.type === "group") {
    return Array.from(fieldData.fields).map((childFieldData) => field.addGroupedField(childFieldData));
  }
};

expose("initializeSurveys", function(globalData, surveyData) {
  surveyFieldTypes = globalData.fields;
  surveyFields = {};

  if (surveyData) {
    return Array.from(surveyData.fields).map((fieldData) => addExistingField(fieldData));
  }
});

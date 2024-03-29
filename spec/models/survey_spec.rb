require "rails_helper"

describe Survey, type: :model do
  let(:definition_hash) do
    {
      "fields" => [
        {
          "type" => "group",
          "label" => "Client Information",
          "min" => 1,
          "max" => nil,
          "fields" => [
            {
              "type" => "text",
              "label" => "Client name or identifier"
            },
            {
              "type" => "text",
              "label" => "Gender or Gender Identification"
            },
            {
              "type" => "select",
              "label" => "Age ranges",
              "options" => [
                "0-17",
                "18-24",
                "25-59",
                "60+",
                "No age"
              ]
            },
            {
              "type" => "text",
              "label" => "Ethnicity"
            },
            {
              "type" => "text",
              "label" => "Type of Appearance"
            },
            {
              "type" => "integer",
              "label" => "How many days of clothing will be required",
              "min" => 1,
              "max" => nil
            },
            {
              "type" => "long_text",
              "label" => "Any other info?"
            }
          ]
        }
      ]
    }
  end

  let(:answers_array) do
    [
      [
        [
          "John Doe",
          "Male",
          1,
          "Caucasian",
          "Tall, short dark hair",
          3,
          "Other info here"
        ],
        [
          "Jane Doe",
          "Female",
          2,
          "Caucasian",
          "Short, long blonde hair",
          2,
          "Some other info here"
        ]
      ]
    ]
  end

  describe "parsing survey from params" do
    let(:params) do
      ActionController::Parameters.new(
        {
          "fields" => {
            "field-3" => {
              "type" => "group",
              "label" => "Grouped Field",
              "required" => "true",
              "min" => "1",
              "max" => "10",
              "fields" => {
                "field-4" => {
                  "type" => "text",
                  "label" => "Short Text Field (optional)"
                },
                "field-5" => {
                  "type" => "group",
                  "label" => "Nested Grouped Field",
                  "required" => "true",
                  "min" => "",
                  "max" => "",
                  "fields" => {
                    "field-7" => {
                      "type" => "integer",
                      "label" => "Double Nested Int",
                      "required" => "true",
                      "min" => "",
                      "max" => ""
                    },
                    "field-8" => {
                      "type" => "text",
                      "label" => "Double Nested Text",
                      "required" => "true"
                    }
                  }
                },
                "field-6" => {
                  "type" => "text",
                  "label" => "Nested Text",
                  "required" => "true"
                }
              }
            },
            "field-9" => {
              "type" => "long_text",
              "label" => "Long Text",
              "required" => "true"
            },
            "field-10" => {
              "type" => "select",
              "label" => "Select",
              "options" => %w[
                First
                Second
                Third
              ],
              "required" => "true"
            }
          }
        }
      )
    end

    it "parses properly into survey definition" do
      definition = SurveyDef::Definition.from_params(params)

      expect(definition.fields.size).to eq(3)

      field = definition.fields[0]
      expect(field).to be_a(SurveyDef::Group)
      expect(field.label).to eq("Grouped Field")
      expect(field.fields.size).to eq(3)
      expect(field.min).to eq(1)
      expect(field.max).to eq(10)
      expect(field.required?).to eq(true)

      field = definition.fields[1]
      expect(field).to be_a(SurveyDef::LongText)
      expect(field.label).to eq("Long Text")
      expect(field.required?).to eq(true)

      field = definition.fields[2]
      expect(field).to be_a(SurveyDef::Select)
      expect(field.label).to eq("Select")
      expect(field.options).to eq(%w[First Second Third])
      expect(field.required?).to eq(true)

      field = definition.fields[0].fields[0]
      expect(field).to be_a(SurveyDef::Text)
      expect(field.label).to eq("Short Text Field (optional)")
      expect(field.required?).to eq(false)

      field = definition.fields[0].fields[1]
      expect(field).to be_a(SurveyDef::Group)
      expect(field.label).to eq("Nested Grouped Field")
      expect(field.fields.size).to eq(2)
      expect(field.min).to be_nil
      expect(field.max).to be_nil
      expect(field.required?).to eq(true)

      field = definition.fields[0].fields[2]
      expect(field).to be_a(SurveyDef::Text)
      expect(field.label).to eq("Nested Text")
      expect(field.required?).to eq(true)

      field = definition.fields[0].fields[1].fields[0]
      expect(field).to be_a(SurveyDef::Integer)
      expect(field.label).to eq("Double Nested Int")
      expect(field.required?).to eq(true)

      field = definition.fields[0].fields[1].fields[1]
      expect(field).to be_a(SurveyDef::Text)
      expect(field.label).to eq("Double Nested Text")
      expect(field.required?).to eq(true)
    end
  end

  describe "definition serialize" do
    it "can serialize object definition to hash" do
      definition = SurveyDef::Definition.new

      definition.fields << SurveyDef::Group.new.tap do |group|
        group.label = "Client Information"
        group.min = 1
        group.max = nil

        group.fields << SurveyDef::Text.new.tap do |field|
          field.label = "Client name or identifier"
        end

        group.fields << SurveyDef::Text.new.tap do |field|
          field.label = "Gender or Gender Identification"
        end

        group.fields << SurveyDef::Select.new.tap do |field|
          field.label = "Age ranges"
          field.options = [
            "0-17",
            "18-24",
            "25-59",
            "60+",
            "No age"
          ]
        end

        group.fields << SurveyDef::Text.new.tap do |field|
          field.label = "Ethnicity"
        end

        group.fields << SurveyDef::Text.new.tap do |field|
          field.label = "Type of Appearance"
        end

        group.fields << SurveyDef::Integer.new.tap do |field|
          field.label = "How many days of clothing will be required"
          field.min = 1
          field.max = nil
        end

        group.fields << SurveyDef::LongText.new.tap do |field|
          field.label = "Any other info?"
        end
      end

      expect(definition.serialize).to eq(definition_hash)
    end

    it "can serialized required vs optional fields" do
      definition = SurveyDef::Definition.new

      definition.fields << SurveyDef::Text.new.tap do |field|
        field.label = "Required Field"
        field.required = true
      end

      definition.fields << SurveyDef::Text.new.tap do |field|
        field.label = "Optional Field"
        field.required = false
      end

      expect(definition.serialize).to eq(
        {
          "fields" => [
            {
              "type" => "text",
              "label" => "Required Field",
              "required" => true
            },
            {
              "type" => "text",
              "label" => "Optional Field"
            }
          ]
        }
      )
    end
  end

  describe "definition parsing" do
    it "can parse a hash into a definition object hierarchy" do
      definition = SurveyDef::Definition.new(definition_hash)
      expect(definition.fields.size).to eq(1)

      field = definition.fields[0]
      expect(field).to be_a(SurveyDef::Group)
      expect(field.label).to eq("Client Information")
      expect(field.fields.size).to eq(7)
      expect(field.min).to eq(1)
      expect(field.max).to be_nil

      field = definition.fields[0].fields[0]
      expect(field).to be_a(SurveyDef::Text)
      expect(field.label).to eq("Client name or identifier")

      field = definition.fields[0].fields[1]
      expect(field).to be_a(SurveyDef::Text)
      expect(field.label).to eq("Gender or Gender Identification")

      field = definition.fields[0].fields[2]
      expect(field).to be_a(SurveyDef::Select)
      expect(field.label).to eq("Age ranges")
      expect(field.options).to eq(["0-17", "18-24", "25-59", "60+", "No age"])

      field = definition.fields[0].fields[3]
      expect(field).to be_a(SurveyDef::Text)
      expect(field.label).to eq("Ethnicity")

      field = definition.fields[0].fields[4]
      expect(field).to be_a(SurveyDef::Text)
      expect(field.label).to eq("Type of Appearance")

      field = definition.fields[0].fields[5]
      expect(field).to be_a(SurveyDef::Integer)
      expect(field.label).to eq("How many days of clothing will be required")
      expect(field.min).to eq(1)
      expect(field.max).to be_nil

      field = definition.fields[0].fields[6]
      expect(field).to be_a(SurveyDef::LongText)
      expect(field.label).to eq("Any other info?")
    end

    it "can parse required vs optional fields" do
      definition_hash = {
        "fields" => [
          {
            "type" => "text",
            "label" => "Optional Example"
          },
          {
            "type" => "text",
            "label" => "Required Example",
            "required" => true
          }
        ]
      }

      definition = SurveyDef::Definition.new(definition_hash)
      expect(definition.fields.size).to eq(2)

      field = definition.fields[0]
      expect(field).to be_a(SurveyDef::Text)
      expect(field.label).to eq("Optional Example")
      expect(field.required?).to eq(false)

      field = definition.fields[1]
      expect(field).to be_a(SurveyDef::Text)
      expect(field.label).to eq("Required Example")
      expect(field.required?).to eq(true)
    end
  end

  describe "answers serialize" do
    it "can serialize object definition to array" do
      definition = SurveyDef::Definition.new(definition_hash)
      answers = SurveyDef::Answers.new

      answers.values << SurveyDef::Group::Answer.new.tap do |group_answer|
        group_answer.field = definition.fields[0]
        group_answer.value = []

        group_answer.value << [].tap do |grouped_answers|
          grouped_answers << SurveyDef::Text::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = "John Doe"
          end

          grouped_answers << SurveyDef::Text::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = "Male"
          end

          grouped_answers << SurveyDef::Select::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = 1
          end

          grouped_answers << SurveyDef::Text::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = "Caucasian"
          end

          grouped_answers << SurveyDef::Text::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = "Tall, short dark hair"
          end

          grouped_answers << SurveyDef::Integer::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = 3
          end

          grouped_answers << SurveyDef::LongText::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = "Other info here"
          end
        end

        group_answer.value << [].tap do |grouped_answers|
          grouped_answers << SurveyDef::Text::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = "Jane Doe"
          end

          grouped_answers << SurveyDef::Text::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = "Female"
          end

          grouped_answers << SurveyDef::Select::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = 2
          end

          grouped_answers << SurveyDef::Text::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = "Caucasian"
          end

          grouped_answers << SurveyDef::Text::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = "Short, long blonde hair"
          end

          grouped_answers << SurveyDef::Integer::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = 2
          end

          grouped_answers << SurveyDef::LongText::Answer.new.tap do |answer|
            answer.field = definition.fields[0].fields[1]
            answer.value = "Some other info here"
          end
        end
      end

      expect(answers.serialize).to eq(answers_array)
    end
  end

  describe "answer parsing" do
    it "can parse an array into an answer object hierarchy" do
      definition = SurveyDef::Definition.new(definition_hash)
      answers = definition.deserialize_answers(answers_array)

      expect(answers).to be_a(SurveyDef::Answers)
      expect(answers.values.size).to eq(1)
      expect(answers.values[0]).to be_a(SurveyDef::Group::Answer)
      expect(answers.values[0].field).to eq(definition.fields[0])
      expect(answers.values[0].value).to be_a(Array)
      expect(answers.values[0].value.size).to eq(2)
      expect(answers.values[0].value[0]).to be_a(Array)
      expect(answers.values[0].value[0].size).to eq(7)
      expect(answers.values[0].value[1]).to be_a(Array)
      expect(answers.values[0].value[1].size).to eq(7)

      expect(answers.values[0].value[0][0]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[0][0].field).to eq(definition.fields[0].fields[0])
      expect(answers.values[0].value[0][0].value).to eq("John Doe")
      expect(answers.values[0].value[0][1]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[0][1].field).to eq(definition.fields[0].fields[1])
      expect(answers.values[0].value[0][1].value).to eq("Male")
      expect(answers.values[0].value[0][2]).to be_a(SurveyDef::Select::Answer)
      expect(answers.values[0].value[0][2].field).to eq(definition.fields[0].fields[2])
      expect(answers.values[0].value[0][2].value).to eq(1)
      expect(answers.values[0].value[0][3]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[0][3].field).to eq(definition.fields[0].fields[3])
      expect(answers.values[0].value[0][3].value).to eq("Caucasian")
      expect(answers.values[0].value[0][4]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[0][4].field).to eq(definition.fields[0].fields[4])
      expect(answers.values[0].value[0][4].value).to eq("Tall, short dark hair")
      expect(answers.values[0].value[0][5]).to be_a(SurveyDef::Integer::Answer)
      expect(answers.values[0].value[0][5].field).to eq(definition.fields[0].fields[5])
      expect(answers.values[0].value[0][5].value).to eq(3)
      expect(answers.values[0].value[0][6]).to be_a(SurveyDef::LongText::Answer)
      expect(answers.values[0].value[0][6].field).to eq(definition.fields[0].fields[6])
      expect(answers.values[0].value[0][6].value).to eq("Other info here")

      expect(answers.values[0].value[1][0]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[1][0].field).to eq(definition.fields[0].fields[0])
      expect(answers.values[0].value[1][0].value).to eq("Jane Doe")
      expect(answers.values[0].value[1][1]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[1][1].field).to eq(definition.fields[0].fields[1])
      expect(answers.values[0].value[1][1].value).to eq("Female")
      expect(answers.values[0].value[1][2]).to be_a(SurveyDef::Select::Answer)
      expect(answers.values[0].value[1][2].field).to eq(definition.fields[0].fields[2])
      expect(answers.values[0].value[1][2].value).to eq(2)
      expect(answers.values[0].value[1][3]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[1][3].field).to eq(definition.fields[0].fields[3])
      expect(answers.values[0].value[1][3].value).to eq("Caucasian")
      expect(answers.values[0].value[1][4]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[1][4].field).to eq(definition.fields[0].fields[4])
      expect(answers.values[0].value[1][4].value).to eq("Short, long blonde hair")
      expect(answers.values[0].value[1][5]).to be_a(SurveyDef::Integer::Answer)
      expect(answers.values[0].value[1][5].field).to eq(definition.fields[0].fields[5])
      expect(answers.values[0].value[1][5].value).to eq(2)
      expect(answers.values[0].value[1][6]).to be_a(SurveyDef::LongText::Answer)
      expect(answers.values[0].value[1][6].field).to eq(definition.fields[0].fields[6])
      expect(answers.values[0].value[1][6].value).to eq("Some other info here")
    end

    it "can parse a non-grouped answer" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "text",
              "label" => "Question 1"
            },
            {
              "type" => "integer",
              "label" => "Question 2"
            }
          ]
        }
      )

      answers = definition.deserialize_answers(["abc", 42])

      expect(answers).to be_a(SurveyDef::Answers)
      expect(answers.values.size).to eq(2)
      expect(answers.values[0]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].field).to eq(definition.fields[0])
      expect(answers.values[0].value).to eq("abc")
      expect(answers.values[1]).to be_a(SurveyDef::Integer::Answer)
      expect(answers.values[1].field).to eq(definition.fields[1])
      expect(answers.values[1].value).to eq(42)
    end

    it "indicates mismatch of number of answers" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "text",
              "label" => "Question 1"
            },
            {
              "type" => "integer",
              "label" => "Question 2"
            }
          ]
        }
      )

      expect { definition.deserialize_answers(["abc"]) }.to raise_error(SurveyDef::SerializationError, /Question count mismatch/)
      expect { definition.deserialize_answers(["abc", 42, "123"]) }.to raise_error(SurveyDef::SerializationError, /Question count mismatch/)
    end

    it "indicates mismatch of number of answers in a grouped answer" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "group",
              "label" => "Group of questions",
              "fields" => [
                {
                  "type" => "text",
                  "label" => "Question 1"
                },
                {
                  "type" => "integer",
                  "label" => "Question 2"
                }
              ]
            }
          ]
        }
      )

      expect { definition.deserialize_answers([[["abc"]]]) }.to raise_error(SurveyDef::SerializationError, /Grouped question count mismatch/)
      expect { definition.deserialize_answers([[["abc", 42, "123"]]]) }.to raise_error(SurveyDef::SerializationError, /Grouped question count mismatch/)

      expect { definition.deserialize_answers([[["abc", 42], ["abc"]]]) }.to raise_error(SurveyDef::SerializationError, /Grouped question count mismatch/)
      expect { definition.deserialize_answers([[["abc", 42], ["abc", 42, "123"]]]) }.to raise_error(SurveyDef::SerializationError, /Grouped question count mismatch/)
    end

    it "indicates type mismatch" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "text",
              "label" => "Question 1"
            },
            {
              "type" => "integer",
              "label" => "Question 2"
            }
          ]
        }
      )

      expect { definition.deserialize_answers(%w[abc 42]) }.to raise_error(SurveyDef::SerializationError, /Type mismatch/)
      expect { definition.deserialize_answers([123, 42]) }.to raise_error(SurveyDef::SerializationError, /Type mismatch/)
    end

    it "indicates group type mismatch" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "group",
              "label" => "Group of questions",
              "fields" => [
                {
                  "type" => "text",
                  "label" => "Question 1"
                },
                {
                  "type" => "integer",
                  "label" => "Question 2"
                }
              ]
            }
          ]
        }
      )

      expect { definition.deserialize_answers([["abc", 42]]) }.to raise_error(SurveyDef::SerializationError, /Type mismatch/)
      expect { definition.deserialize_answers(["abc"]) }.to raise_error(SurveyDef::SerializationError, /Type mismatch/)
    end

    it "indicates missing required answers" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "text",
              "label" => "Optional Example"
            },
            {
              "type" => "text",
              "label" => "Required Example",
              "required" => true
            }
          ]
        }
      )

      expect { definition.deserialize_answers(["", ""]) }.to raise_error(SurveyDef::SerializationError, /Answer required/)
      expect { definition.deserialize_answers(["Optional answer", ""]) }.to raise_error(SurveyDef::SerializationError, /Answer required/)
      expect { definition.deserialize_answers(["", "Required answer"]) }.to_not raise_error
    end
  end

  describe "generating blank answers from survey" do
    it "can generate simple blank answers" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "text",
              "label" => "Simple Text"
            },
            {
              "type" => "long_text",
              "label" => "Simple Long Text"
            },
            {
              "type" => "integer",
              "label" => "Simple Integer"
            },
            {
              "type" => "select",
              "label" => "Simple Select",
              "options" => %w[
                First
                Second
                Third
              ]
            }
          ]
        }
      )

      expect(definition.blank_answers).to eq([nil, nil, nil, nil])
    end

    it "ignores required fields" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "text",
              "label" => "Simple Text",
              "required" => true
            },
            {
              "type" => "integer",
              "label" => "Simple Integer",
              "required" => true
            }
          ]
        }
      )

      expect(definition.blank_answers).to eq([nil, nil])
    end

    it "ignores minimum and maximum values" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "integer",
              "label" => "Simple Integer",
              "min" => 3
            },
            {
              "type" => "integer",
              "label" => "Simple Integer",
              "max" => 3
            }
          ]
        }
      )

      expect(definition.blank_answers).to eq([nil, nil])
    end

    it "honors grouped fields" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "group",
              "label" => "Simple Grouped",
              "fields" => [
                {
                  "type" => "integer",
                  "label" => "Simple Integer"
                },
                {
                  "type" => "text",
                  "label" => "Simple Text"
                }
              ]
            }
          ]
        }
      )

      expect(definition.blank_answers).to eq([[]])
    end

    it "honors minimum grouped fields" do
      definition = SurveyDef::Definition.new(
        {
          "fields" => [
            {
              "type" => "group",
              "label" => "Simple Grouped",
              "min" => 2,
              "fields" => [
                {
                  "type" => "integer",
                  "label" => "Simple Integer"
                },
                {
                  "type" => "text",
                  "label" => "Simple Text"
                }
              ]
            }
          ]
        }
      )

      expect(definition.blank_answers).to eq([[[nil, nil], [nil, nil]]])
    end
  end

  describe "parsing survey answers from params" do
    let(:params) do
      ActionController::Parameters.new(
        {
          "0" => {
            "group_5" => {
              "0" => "Jennifer Doe",
              "1" => "Female",
              "2" => "2",
              "3" => "Asian",
              "4" => "Tall, long dark hair",
              "5" => "42",
              "6" => "More info here"
            },
            "group_21" => {
              "0" => "Jack Doe",
              "1" => "Male",
              "2" => "3",
              "3" => "Caucasian",
              "4" => "Short, short blonde hair",
              "5" => "10",
              "6" => "More other info here"
            }
          }
        }
      )
    end

    it "parses properly into survey definition" do
      definition = SurveyDef::Definition.new(definition_hash)
      answers = definition.answers_from_params(params)

      expect(answers).to be_a(SurveyDef::Answers)
      expect(answers.values.size).to eq(1)
      expect(answers.values[0]).to be_a(SurveyDef::Group::Answer)
      expect(answers.values[0].field).to eq(definition.fields[0])
      expect(answers.values[0].value).to be_a(Array)
      expect(answers.values[0].value.size).to eq(2)
      expect(answers.values[0].value[0]).to be_a(Array)
      expect(answers.values[0].value[0].size).to eq(7)
      expect(answers.values[0].value[1]).to be_a(Array)
      expect(answers.values[0].value[1].size).to eq(7)

      expect(answers.values[0].value[0][0]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[0][0].field).to eq(definition.fields[0].fields[0])
      expect(answers.values[0].value[0][0].value).to eq("Jennifer Doe")
      expect(answers.values[0].value[0][1]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[0][1].field).to eq(definition.fields[0].fields[1])
      expect(answers.values[0].value[0][1].value).to eq("Female")
      expect(answers.values[0].value[0][2]).to be_a(SurveyDef::Select::Answer)
      expect(answers.values[0].value[0][2].field).to eq(definition.fields[0].fields[2])
      expect(answers.values[0].value[0][2].value).to eq(2)
      expect(answers.values[0].value[0][3]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[0][3].field).to eq(definition.fields[0].fields[3])
      expect(answers.values[0].value[0][3].value).to eq("Asian")
      expect(answers.values[0].value[0][4]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[0][4].field).to eq(definition.fields[0].fields[4])
      expect(answers.values[0].value[0][4].value).to eq("Tall, long dark hair")
      expect(answers.values[0].value[0][5]).to be_a(SurveyDef::Integer::Answer)
      expect(answers.values[0].value[0][5].field).to eq(definition.fields[0].fields[5])
      expect(answers.values[0].value[0][5].value).to eq(42)
      expect(answers.values[0].value[0][6]).to be_a(SurveyDef::LongText::Answer)
      expect(answers.values[0].value[0][6].field).to eq(definition.fields[0].fields[6])
      expect(answers.values[0].value[0][6].value).to eq("More info here")

      expect(answers.values[0].value[1][0]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[1][0].field).to eq(definition.fields[0].fields[0])
      expect(answers.values[0].value[1][0].value).to eq("Jack Doe")
      expect(answers.values[0].value[1][1]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[1][1].field).to eq(definition.fields[0].fields[1])
      expect(answers.values[0].value[1][1].value).to eq("Male")
      expect(answers.values[0].value[1][2]).to be_a(SurveyDef::Select::Answer)
      expect(answers.values[0].value[1][2].field).to eq(definition.fields[0].fields[2])
      expect(answers.values[0].value[1][2].value).to eq(3)
      expect(answers.values[0].value[1][3]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[1][3].field).to eq(definition.fields[0].fields[3])
      expect(answers.values[0].value[1][3].value).to eq("Caucasian")
      expect(answers.values[0].value[1][4]).to be_a(SurveyDef::Text::Answer)
      expect(answers.values[0].value[1][4].field).to eq(definition.fields[0].fields[4])
      expect(answers.values[0].value[1][4].value).to eq("Short, short blonde hair")
      expect(answers.values[0].value[1][5]).to be_a(SurveyDef::Integer::Answer)
      expect(answers.values[0].value[1][5].field).to eq(definition.fields[0].fields[5])
      expect(answers.values[0].value[1][5].value).to eq(10)
      expect(answers.values[0].value[1][6]).to be_a(SurveyDef::LongText::Answer)
      expect(answers.values[0].value[1][6].field).to eq(definition.fields[0].fields[6])
      expect(answers.values[0].value[1][6].value).to eq("More other info here")
    end
  end
end

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

  let(:answers) do
    {
      "fields" => [
        {
          "fields" => [
            "John Doe",
            "Male",
            1,
            "Caucasian",
            "Tall, short dark hair",
            3,
            "Other info here"
          ]
        },
        {
          "fields" => [
            "Jane Doe",
            "Female",
            2,
            "Caucasian",
            "Short, long blonde hair",
            2,
            "Some other info here"
          ]
        }
      ]
    }
  end

  describe "definition to_h" do
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

      expect(definition.to_h).to eq(definition_hash)
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
  end

  describe "answer parsing" do
    it "will be decided later"
  end
end

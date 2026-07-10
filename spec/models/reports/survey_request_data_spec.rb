require "rails_helper"

describe Reports::SurveyRequestData, type: :model do
  let(:survey) { surveys(:active_survey) }
  let(:survey_request) { survey_requests(:basic_survey_request) }
  let(:org_request) { survey_organization_requests(:foo_unanswered_org_request) }

  subject(:data) { described_class.new(survey_request) }

  let(:group_survey_request) do
    revision = survey.survey_revisions.create!(
      title: "group_v1",
      active: false,
      definition: {
        "fields" => [
          {
            "type" => "group",
            "label" => "Family Members",
            "min" => 1,
            "max" => 5,
            "fields" => [{ "type" => "integer", "label" => "Age" }]
          }
        ]
      }
    )
    SurveyRequest.create!(
      title: "Group Survey Request",
      survey: survey,
      survey_revision: revision
    ).tap do |req|
      req.survey_organization_requests.create!(organization: organizations(:acme))
      req.update_organization_counts
    end
  end

  describe "#columns" do
    it "returns column objects including an Organization column" do
      cols = data.columns
      expect(cols).to be_an(Array)
      expect(cols.map(&:label)).to include("Organization")
    end

    it "returns a column for each survey field" do
      cols = data.columns
      expect(cols.size).to be >= 2
    end
  end

  describe "#csv_export_header" do
    it "returns column labels as strings" do
      header = data.csv_export_header
      expect(header).to be_an(Array)
      expect(header.first).to eq("Organization")
    end
  end

  describe "#csv_export_row" do
    it "flattens row values into an array" do
      row = [1, 2, 3]
      expect(data.csv_export_row(row)).to eq([1, 2, 3])
    end
  end

  describe "#each" do
    it "yields a Row for each survey_organization_request" do
      first_row = nil
      count = 0
      data.each do |row|
        first_row ||= row
        count += 1
      end
      expect(count).to be > 0
      expect(first_row).to be_a(Reports::SurveyRequestData::Row)
    end
  end

  describe "Column" do
    let(:column) do
      Reports::SurveyRequestData::Column.new("Test Label", css_class: "sort-asc") { |_req, _ans| "value" }
    end

    it "exposes label and css_class" do
      expect(column.label).to eq("Test Label")
      expect(column.css_class).to eq("sort-asc")
    end

    it "#apply calls the block with org_request and answers" do
      expect(column.apply(org_request, nil)).to eq("value")
    end
  end

  describe "grouped field columns" do
    subject(:group_data) { described_class.new(group_survey_request) }

    it "generates a count column and integer aggregate columns for group+integer fields" do
      cols = group_data.columns
      labels = cols.map(&:label)
      expect(labels).to include("Organization")
      expect(labels).to include("# of Family Members")
      expect(labels).to include("Min Age")
      expect(labels).to include("Max Age")
      expect(labels).to include("Avg Age")
      expect(labels).to include("Total Age")
    end

    it "returns nil for aggregate columns when answers are nil" do
      org_req = group_survey_request.survey_organization_requests.first
      row = Reports::SurveyRequestData::Row.new(group_data, org_req, nil)
      index = 0
      first_value = nil
      second_value = :unset
      row.each do |v|
        first_value = v if index == 0
        second_value = v if index == 1
        index += 1
      end
      expect(first_value).to eq(org_req.organization.name)
      expect(second_value).to be_nil
    end
  end

  describe "Row" do
    let(:row) { Reports::SurveyRequestData::Row.new(data, org_request, nil) }

    it "exposes org_request and answers" do
      expect(row.org_request).to eq(org_request)
      expect(row.answers).to be_nil
    end

    it "#status_class delegates to org_request" do
      expect(row.status_class).to eq(org_request.status_class)
    end

    it "#each yields each column value" do
      count = 0
      first_value = nil
      row.each do |v|
        first_value ||= v
        count += 1
      end
      expect(count).to eq(data.columns.size)
      expect(first_value).to eq(org_request.organization.name)
    end
  end
end

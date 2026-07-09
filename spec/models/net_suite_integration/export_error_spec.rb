require "rails_helper"

describe NetSuiteIntegration::ExportError, type: :model do
  let(:error_record) do
    double(
      errors: [double(type: "Error", code: "INVALID_KEY_OR_REF", message: "Invalid reference")],
      size: 1
    )
  end

  describe "#failure_details" do
    it "includes NetSuite error info and backtrace" do
      begin
        raise NetSuiteIntegration::ExportError.new("Failed to export!", error_record)
      rescue NetSuiteIntegration::ExportError => e
        details = e.failure_details
        expect(details).to include("NetSuite errors:")
        expect(details).to include("Exception details: Failed to export!")
      end
    end

    it "memoizes the result" do
      begin
        raise NetSuiteIntegration::ExportError.new("Failure", error_record)
      rescue NetSuiteIntegration::ExportError => e
        expect(e.failure_details).to be(e.failure_details)
      end
    end
  end
end

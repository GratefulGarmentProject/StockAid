require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#bootstrap_class_for" do
    it "returns alert-success for :success" do
      expect(helper.bootstrap_class_for(:success)).to eq("alert-success")
    end

    it "returns alert-warning for :notice" do
      expect(helper.bootstrap_class_for(:notice)).to eq("alert-warning")
    end

    it "returns alert-info for :info" do
      expect(helper.bootstrap_class_for(:info)).to eq("alert-info")
    end
  end

  describe "#external_id_or_status" do
    let(:object) { donors(:picard) }

    before do
      allow(NetSuiteIntegration).to receive(:external_id_for).and_return(123)
      allow(NetSuiteIntegration).to receive(:export_queued?).and_return(false)
      allow(NetSuiteIntegration).to receive(:export_in_progress?).and_return(false)
      allow(NetSuiteIntegration).to receive(:export_failed?).and_return(false)
      allow(NetSuiteIntegration).to receive(:export_not_applicable?).and_return(false)
    end

    it "returns nil when no external_id" do
      allow(NetSuiteIntegration).to receive(:external_id_for).and_return(nil)
      expect(helper.external_id_or_status(object)).to be_nil
    end

    it "returns 'Export queued' tag when export queued" do
      allow(NetSuiteIntegration).to receive(:export_queued?).and_return(true)
      expect(helper.external_id_or_status(object)).to include("Export queued")
    end

    it "returns 'Export in progress' tag when in progress" do
      allow(NetSuiteIntegration).to receive(:export_in_progress?).and_return(true)
      expect(helper.external_id_or_status(object)).to include("Export in progress")
    end

    it "returns 'Export failed!' tag when failed" do
      allow(NetSuiteIntegration).to receive(:export_failed?).and_return(true)
      expect(helper.external_id_or_status(object)).to include("Export failed!")
    end

    it "returns 'N/A' tag when not applicable" do
      allow(NetSuiteIntegration).to receive(:export_not_applicable?).and_return(true)
      expect(helper.external_id_or_status(object)).to include("N/A")
    end

    it "returns external_id when no special status and link is false" do
      expect(helper.external_id_or_status(object)).to eq(123)
    end
  end

  describe "#external_link" do
    let(:object) { donors(:picard) }

    it "returns external_id when netsuite is not initialized" do
      allow(NetSuiteIntegration).to receive(:external_id_for).and_return(123)
      allow(Rails.application.config).to receive(:netsuite_initialized).and_return(false)
      expect(helper.external_link(object)).to eq(123)
    end

    it "returns a link tag when netsuite is initialized and path exists" do
      allow(NetSuiteIntegration).to receive(:external_id_for).and_return(123)
      allow(Rails.application.config).to receive(:netsuite_initialized).and_return(true)
      allow(NetSuiteIntegration).to receive(:path).and_return("https://netsuite.example.com/123")
      result = helper.external_link(object)
      expect(result).to include("123")
    end

    it "returns external_id when netsuite is initialized but path is nil" do
      allow(NetSuiteIntegration).to receive(:external_id_for).and_return(123)
      allow(Rails.application.config).to receive(:netsuite_initialized).and_return(true)
      allow(NetSuiteIntegration).to receive(:path).and_return(nil)
      expect(helper.external_link(object)).to eq(123)
    end
  end
end

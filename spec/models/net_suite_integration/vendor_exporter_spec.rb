require "rails_helper"

describe NetSuiteIntegration::VendorExporter, type: :model do
  include ActiveJob::TestHelper

  let(:vendor) { vendors(:guinan) }

  describe ".create_and_export" do
    it "creates a vendor without exporting when save_and_export is false" do
      vendor_params = ActionController::Parameters.new(
        name: "New Test Vendor",
        addresses_attributes: {}
      ).permit!
      expect { described_class.create_and_export(vendor_params, false) }.to change(Vendor, :count).by(1)
    end

    it "queues export when save_and_export is true" do
      vendor_params = ActionController::Parameters.new(
        name: "Export Test Vendor",
        addresses_attributes: {}
      ).permit!
      expect { described_class.create_and_export(vendor_params, true) }.to have_enqueued_job(ExportVendorJob)
    end
  end

  describe "#export_later" do
    it "enqueues ExportVendorJob" do
      expect { described_class.new(vendor).export_later }.to have_enqueued_job(ExportVendorJob)
    end

    it "marks the vendor as queued" do
      described_class.new(vendor).export_later
      expect(NetSuiteIntegration.export_queued?(vendor)).to be true
    end
  end

  describe "#export" do
    context "with a company vendor" do
      it "exports the vendor and sets external_id" do
        expect_any_instance_of(NetSuite::Records::Vendor).to receive(:add) do |vendor_record|
          allow(vendor_record).to receive(:internal_id).and_return("99")
          true
        end.once

        described_class.new(vendor).export
        expect(vendor.reload.external_id).to eq(99)
      end

      it "raises ExportError when add fails" do
        expect_any_instance_of(NetSuite::Records::Vendor).to receive(:add).and_return(false)

        expect { described_class.new(vendor).export }.to raise_error(NetSuiteIntegration::ExportError)
      end
    end

    context "with an individual vendor" do
      before { vendor.update_column(:external_type, "Individual") }

      it "exports the vendor as a person" do
        expect_any_instance_of(NetSuite::Records::Vendor).to receive(:add) do |vendor_record|
          allow(vendor_record).to receive(:internal_id).and_return("100")
          true
        end.once

        described_class.new(vendor).export
        expect(vendor.reload.external_id).to eq(100)
      end
    end

    it "syncs via the job queue when using export_later" do
      expect_any_instance_of(NetSuite::Records::Vendor).to receive(:add) do |vendor_record|
        allow(vendor_record).to receive(:internal_id).and_return("101")
        true
      end.once

      perform_enqueued_jobs do
        described_class.new(vendor).export_later
      end

      expect(vendor.reload.external_id).to eq(101)
    end
  end
end

require "rails_helper"

describe NetSuiteIntegration::DonorExporter, type: :model do
  include ActiveJob::TestHelper

  let(:donor) { donors(:picard) }

  describe ".person_type?" do
    it "returns true for individual types" do
      expect(described_class.person_type?("Individual")).to be true
      expect(described_class.person_type?("Household")).to be true
      expect(described_class.person_type?("Board of Director")).to be true
    end

    it "returns false for organization types" do
      expect(described_class.person_type?("Organization")).to be false
      expect(described_class.person_type?("Agency")).to be false
    end
  end

  describe ".find_or_create_and_export" do
    it "finds existing donor when selected_donor is an id" do
      result = described_class.find_or_create_and_export(selected_donor: donor.id.to_s)
      expect(result).to eq(donor)
    end

    it "creates a new donor when selected_donor is 'new'" do
      params = ActionController::Parameters.new(
        selected_donor: "new",
        donor: { name: "Brand New Donor", external_type: "Individual", addresses_attributes: {} },
        save_and_export_donor: "false"
      )
      result = described_class.find_or_create_and_export(params)
      expect(result).to be_a(Donor)
      expect(result.name).to eq("Brand New Donor")
    end

    it "raises when selected_donor is blank" do
      expect { described_class.find_or_create_and_export(selected_donor: "") }.to raise_error(/Missing selected_donor/)
    end
  end

  describe ".create_and_export" do
    let(:base_params) do
      { donor: { name: "New Test Donor", external_type: "Individual", addresses_attributes: {} } }
    end

    it "creates a donor without exporting when save_and_export_donor is not true" do
      params = ActionController::Parameters.new(base_params.merge(save_and_export_donor: "false"))
      expect { described_class.create_and_export(params) }.to change(Donor, :count).by(1)
    end

    it "queues export when save_and_export_donor is true" do
      params = ActionController::Parameters.new(
        base_params.merge(
          donor: base_params[:donor].merge(name: "Export Test Donor"),
          save_and_export_donor: "true"
        )
      )
      expect { described_class.create_and_export(params) }.to have_enqueued_job(ExportDonorJob)
    end
  end

  describe "#export_later" do
    it "enqueues ExportDonorJob" do
      expect { described_class.new(donor).export_later }.to have_enqueued_job(ExportDonorJob)
    end

    it "marks the donor as queued" do
      described_class.new(donor).export_later
      expect(NetSuiteIntegration.export_queued?(donor)).to be true
    end
  end

  describe "#export" do
    context "with an individual donor" do
      before { donor.update_column(:external_type, "Individual") }

      it "exports the donor and sets external_id" do
        expect_any_instance_of(NetSuite::Records::Customer).to receive(:add) do |customer|
          allow(customer).to receive(:internal_id).and_return("77")
          true
        end.once

        described_class.new(donor).export
        expect(donor.reload.external_id).to eq(77)
      end

      it "raises ExportError when add fails" do
        expect_any_instance_of(NetSuite::Records::Customer).to receive(:add).and_return(false)

        expect { described_class.new(donor).export }.to raise_error(NetSuiteIntegration::ExportError)
      end
    end

    context "with an organization donor" do
      before { donor.update_column(:external_type, "Organization") }

      it "exports the donor as a company" do
        expect_any_instance_of(NetSuite::Records::Customer).to receive(:add) do |customer|
          allow(customer).to receive(:internal_id).and_return("78")
          true
        end.once

        described_class.new(donor).export
        expect(donor.reload.external_id).to eq(78)
      end
    end

    context "when export_later is called" do
      before { donor.update_column(:external_type, "Individual") }

      it "syncs via the job queue" do
        expect_any_instance_of(NetSuite::Records::Customer).to receive(:add) do |customer|
          allow(customer).to receive(:internal_id).and_return("79")
          true
        end.once

        perform_enqueued_jobs do
          described_class.new(donor).export_later
        end

        expect(donor.reload.external_id).to eq(79)
      end
    end
  end
end

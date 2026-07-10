require "rails_helper"

describe NetSuiteIntegration::OrganizationExporter, type: :model do
  include ActiveJob::TestHelper

  let(:organization) { organizations(:no_order_org) }

  before do
    organization.update_columns(external_id: nil, external_type: "Agency")
  end

  describe ".create_and_export" do
    let(:base_org_params) do
      {
        name: "New Test Org",
        external_type: "Agency",
        organization_county_id: counties(:santa_clara).id,
        addresses_attributes: {},
        program_ids: [programs(:resource_closets).id]
      }
    end

    it "creates an organization without exporting when save_and_export_organization is not true" do
      params = ActionController::Parameters.new(
        organization: base_org_params,
        save_and_export_organization: "false"
      )
      expect { described_class.create_and_export(params) }.to change(Organization, :count).by(1)
    end

    it "queues export when save_and_export_organization is true" do
      params = ActionController::Parameters.new(
        organization: base_org_params.merge(name: "Export Test Org"),
        save_and_export_organization: "true"
      )
      expect { described_class.create_and_export(params) }.to have_enqueued_job(ExportOrganizationJob)
    end
  end

  describe "#export_later" do
    it "enqueues ExportOrganizationJob" do
      expect { described_class.new(organization).export_later }.to have_enqueued_job(ExportOrganizationJob)
    end

    it "marks the organization as queued" do
      described_class.new(organization).export_later
      expect(NetSuiteIntegration.export_queued?(organization)).to be true
    end
  end

  describe "#export" do
    it "exports the organization and sets external_id" do
      expect_any_instance_of(NetSuite::Records::Customer).to receive(:add) do |customer|
        allow(customer).to receive(:internal_id).and_return("200")
        true
      end.once

      described_class.new(organization).export
      expect(organization.reload.external_id).to eq(200)
    end

    it "raises ExportError when add fails" do
      expect_any_instance_of(NetSuite::Records::Customer).to receive(:add).and_return(false)

      expect { described_class.new(organization).export }.to raise_error(NetSuiteIntegration::ExportError)
    end

    it "syncs via the job queue when using export_later" do
      expect_any_instance_of(NetSuite::Records::Customer).to receive(:add) do |customer|
        allow(customer).to receive(:internal_id).and_return("201")
        true
      end.once

      perform_enqueued_jobs do
        described_class.new(organization).export_later
      end

      expect(organization.reload.external_id).to eq(201)
    end
  end
end

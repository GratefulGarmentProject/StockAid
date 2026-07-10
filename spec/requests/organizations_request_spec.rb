require "rails_helper"

RSpec.describe OrganizationsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get organizations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_organization_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "renders ok" do
      get organization_path(organizations(:acme))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#edit" do
    it "renders ok" do
      get edit_organization_path(organizations(:acme))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates an organization and redirects" do
      post organizations_path, params: {
        organization: {
          name: "New Test Org",
          organization_county_id: counties(:santa_clara).id,
          program_ids: [programs(:resource_closets).id],
          addresses_attributes: { "0" => { address: "" } }
        }
      }
      expect(response).to redirect_to(organizations_path)
      expect(Organization.find_by(name: "New Test Org")).to be_present
    end

    it "re-renders new when name is a duplicate" do
      post organizations_path, params: {
        organization: {
          name: organizations(:acme).name,
          addresses_attributes: { "0" => { address: "" } }
        }
      }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update" do
    let(:org) { organizations(:acme) }

    it "updates and redirects" do
      patch organization_path(org), params: {
        organization: {
          name: "ACME Updated",
          addresses_attributes: { "0" => { address: "" } }
        }
      }
      expect(response).to redirect_to(organizations_path)
      expect(org.reload.name).to eq("ACME Updated")
    end
  end

  describe "#destroy" do
    it "deletes and redirects" do
      delete organization_path(organizations(:no_order_org))
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to be_present
    end
  end

  describe "#deleted" do
    it "renders ok" do
      get deleted_organizations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#restore" do
    let(:org) { organizations(:no_order_org) }

    before { org.soft_delete }

    it "restores and redirects" do
      patch restore_organization_path(org)
      expect(response).to have_http_status(:found)
    end
  end

  describe "#by_program" do
    it "renders ok" do
      get by_program_organizations_path, params: { program: programs(:resource_closets).id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#netsuite_import" do
    it "imports organization and redirects to edit" do
      allow_any_instance_of(NetSuiteIntegration::OrganizationImporter).to receive(:import)
        .and_return(organizations(:acme))
      post netsuite_import_organizations_path, params: { external_id: "789", organization: { program_ids: [] } }
      expect(response).to redirect_to(edit_organization_path(organizations(:acme)))
    end

    it "renders new with error when import fails" do
      allow_any_instance_of(NetSuiteIntegration::OrganizationImporter).to receive(:import)
        .and_raise(ActiveRecord::RecordInvalid.new(Organization.new))
      post netsuite_import_organizations_path, params: { external_id: "789", organization: { program_ids: [] } }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get organizations_path }.to raise_error(PermissionError)
    end
  end
end

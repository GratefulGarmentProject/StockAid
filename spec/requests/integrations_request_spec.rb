require "rails_helper"

RSpec.describe IntegrationsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#show" do
    it "renders ok" do
      get integrations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get integrations_path }.to raise_error(PermissionError)
    end
  end
end

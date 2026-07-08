require "rails_helper"

RSpec.describe NetSuiteErrorsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get net_suite_errors_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "renders ok" do
      get net_suite_error_path(failed_net_suite_exports(:sample_netsuite_error))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#destroy" do
    it "deletes the error and redirects" do
      error = failed_net_suite_exports(:sample_netsuite_error)
      delete net_suite_error_path(error)
      expect(response).to redirect_to(net_suite_errors_path)
      expect(flash[:success]).to be_present
      expect(FailedNetSuiteExport.find_by(id: error.id)).to be_nil
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get net_suite_errors_path }.to raise_error(PermissionError)
    end
  end
end

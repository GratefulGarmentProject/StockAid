require "rails_helper"

RSpec.describe InventoryReconciliationsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get inventory_reconciliations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#completed" do
    it "renders ok" do
      get completed_inventory_reconciliations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a reconciliation and redirects to count_sheets" do
      expect {
        post inventory_reconciliations_path, params: { title: "Test Reconciliation" }
      }.to change(InventoryReconciliation, :count).by(1)
      reconciliation = InventoryReconciliation.order(:id).last
      expect(response).to redirect_to(inventory_reconciliation_count_sheets_path(reconciliation))
      expect(flash[:success]).to be_present
    end
  end

  describe "#destroy" do
    let(:reconciliation) { inventory_reconciliations(:open_reconciliation) }

    it "deletes the reconciliation and redirects" do
      delete inventory_reconciliation_path(reconciliation)
      expect(response).to redirect_to(inventory_reconciliations_path)
      expect(InventoryReconciliation.find_by(id: reconciliation.id)).to be_nil
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get inventory_reconciliations_path }.to raise_error(PermissionError)
    end
  end
end

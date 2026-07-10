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
      expect do
        post inventory_reconciliations_path, params: { title: "Test Reconciliation" }
      end.to change(InventoryReconciliation, :count).by(1)
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

  describe "#deltas" do
    let(:reconciliation) { inventory_reconciliations(:in_progress_reconciliation) }

    it "renders ok" do
      get deltas_inventory_reconciliation_path(reconciliation)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#ignored_bins" do
    let(:reconciliation) { inventory_reconciliations(:open_reconciliation) }

    it "renders ok" do
      get ignored_bins_inventory_reconciliation_path(reconciliation)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#print_prep" do
    it "renders ok with blank_print layout" do
      get print_prep_inventory_reconciliations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#comment" do
    let(:reconciliation) { inventory_reconciliations(:open_reconciliation) }

    it "creates a comment and redirects" do
      post comment_inventory_reconciliation_path(reconciliation), params: { content: "Test comment" }
      expect(response).to have_http_status(:found)
      expect(reconciliation.reconciliation_notes.last&.content).to eq("Test comment")
    end
  end

  describe "#unignore_bin" do
    let(:reconciliation) { inventory_reconciliations(:open_reconciliation) }

    before do
      bin = bins(:flip_flop_bin)
      reconciliation.update!(ignored_bin_ids: [bin.id])
    end

    it "unignores a bin and redirects to ignored_bins" do
      bin = bins(:flip_flop_bin)
      post unignore_bin_inventory_reconciliation_path(reconciliation), params: { bin_id: bin.id }
      expect(response).to redirect_to(ignored_bins_inventory_reconciliation_path(reconciliation))
      expect(reconciliation.reload.ignored_bin_ids).not_to include(bin.id)
    end
  end

  describe "#complete" do
    it "raises PermissionError when reconciliation is not ready" do
      reconciliation = inventory_reconciliations(:in_progress_reconciliation)
      expect do
        post complete_inventory_reconciliation_path(reconciliation)
      end.to raise_error(PermissionError)
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get inventory_reconciliations_path }.to raise_error(PermissionError)
    end
  end
end

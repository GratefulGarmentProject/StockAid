require "rails_helper"

RSpec.describe CountSheetsController, type: :request do
  let(:super_admin) { users(:root) }
  let(:reconciliation) { inventory_reconciliations(:in_progress_reconciliation) }
  let(:count_sheet) { count_sheets(:flip_flop_count_sheet) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get inventory_reconciliation_count_sheets_path(reconciliation)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "renders the count sheet" do
      get inventory_reconciliation_count_sheet_path(reconciliation, count_sheet)
      expect(response).to have_http_status(:ok)
    end

    it "renders the misfits count sheet" do
      get inventory_reconciliation_count_sheet_path(reconciliation, "misfits")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update" do
    it "marks a sheet incomplete and redirects" do
      patch inventory_reconciliation_count_sheet_path(reconciliation, count_sheet), params: {
        counter_names: ["Alice", ""],
        incomplete: "1",
        final_counts: {}
      }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to be_present
    end
  end

  describe "#destroy" do
    it "destroys the count sheet and redirects to count sheets index" do
      expect do
        delete inventory_reconciliation_count_sheet_path(reconciliation, count_sheet)
      end.to change(CountSheet, :count).by(-1)
      expect(response).to redirect_to(inventory_reconciliation_count_sheets_path(reconciliation))
      expect(flash[:success]).to be_present
    end
  end

  describe "#destroy_unnecessary" do
    it "deletes unnecessary count sheets and redirects" do
      delete unnecessary_inventory_reconciliation_count_sheets_path(reconciliation)
      expect(response).to redirect_to(inventory_reconciliation_count_sheets_path(reconciliation))
      expect(flash[:success]).to be_present
    end
  end
end

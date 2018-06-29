require "rails_helper"

describe CountSheetsController, type: :controller do
  let(:open_reconciliation) { inventory_reconciliations(:open_reconciliation) }
  let(:flip_flop_bin) { bins(:flip_flop_bin) }
  let(:deleted_bin) { bins(:deleted_bin) }
  let(:empty_bin) { bins(:empty_bin) }

  describe "GET index" do
    it "creates count sheets for bins that don't have count sheets yet" do
      signed_in_user :root
      get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
      sheet = open_reconciliation.count_sheets.where(bin: flip_flop_bin).first
      expect(sheet).to be_present
      expect(flip_flop_bin.bin_items.size).to_not be_zero
      expect(flip_flop_bin.bin_items.pluck(:item_id).sort).to eq(sheet.count_sheet_details.pluck(:item_id).sort)
    end

    it "doesn't create count sheets for deleted bins" do
      signed_in_user :root
      get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
      expect(open_reconciliation.count_sheets.where(bin: deleted_bin).first).to be_blank
    end

    it "doesn't create count sheets for empty bins" do
      signed_in_user :root
      get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
      expect(open_reconciliation.count_sheets.where(bin: empty_bin).first).to be_blank
    end

    context "with views" do
      render_views

      it "displays the count sheets" do
        signed_in_user :root
        get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
        expect(response.body).to have_selector("td", text: flip_flop_bin.label)
      end
    end
  end
end

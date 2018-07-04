require "rails_helper"

describe CountSheetsController, type: :controller do
  let(:open_reconciliation) { inventory_reconciliations(:open_reconciliation) }
  let(:flip_flop_bin) { bins(:flip_flop_bin) }
  let(:deleted_bin) { bins(:deleted_bin) }
  let(:empty_bin) { bins(:empty_bin) }

  let(:in_progress_reconciliation) { inventory_reconciliations(:in_progress_reconciliation) }
  let(:flip_flop_count_sheet) { count_sheets(:flip_flop_count_sheet) }
  let(:small_flip_flops_count_sheet_detail) { count_sheet_details(:small_flip_flops_count_sheet_detail) }
  let(:large_flip_flops_count_sheet_detail) { count_sheet_details(:large_flip_flops_count_sheet_detail) }

  before { signed_in_user :root }

  describe "GET index" do
    it "creates count sheets for bins that don't have count sheets yet" do
      get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
      sheet = open_reconciliation.count_sheets.where(bin: flip_flop_bin).first
      expect(sheet).to be_present
      expect(flip_flop_bin.bin_items.size).to_not be_zero
      expect(flip_flop_bin.bin_items.pluck(:item_id).sort).to eq(sheet.count_sheet_details.pluck(:item_id).sort)
    end

    it "doesn't create count sheets for deleted bins" do
      get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
      expect(open_reconciliation.count_sheets.where(bin: deleted_bin).first).to be_blank
    end

    it "doesn't create count sheets for empty bins" do
      get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
      expect(open_reconciliation.count_sheets.where(bin: empty_bin).first).to be_blank
    end

    context "with views" do
      render_views

      it "displays the count sheets" do
        get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
        expect(response.body).to have_selector("td", text: flip_flop_bin.label)
      end
    end
  end

  describe "PUT update" do
    it "allows saving values for the count sheet" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        }
      }

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar", "Baz Qux"])
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1, 2])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3, 4])
    end

    xit "allows saving additional columns for the count sheet" do
    end

    xit "allows deleting columns for the count sheet by leaving them out" do
    end

    xit "allows marking the count sheet as completed" do
    end

    xit "blocks saving the count sheet once it is completed" do
    end
  end
end

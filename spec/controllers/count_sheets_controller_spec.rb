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

  let(:small_flip_flops) { items(:small_flip_flops) }
  let(:medium_flip_flops) { items(:medium_flip_flops) }

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

  describe "GET show" do
    it "creates rows in the count sheet for bin items that are new" do
      expect(flip_flop_count_sheet.items).to_not include(medium_flip_flops)
      flip_flop_bin.bin_items.create! item: medium_flip_flops
      get :show, params: { inventory_reconciliation_id: in_progress_reconciliation.id.to_s, id: flip_flop_count_sheet.id.to_s }
      flip_flop_count_sheet.reload
      expect(flip_flop_count_sheet.items).to include(medium_flip_flops)
    end

    it "doesn't create rows when the count sheet is complete" do
      expect(flip_flop_count_sheet.items).to_not include(medium_flip_flops)
      flip_flop_bin.bin_items.create! item: medium_flip_flops
      flip_flop_count_sheet.counter_names = %w(Foo Bar)

      flip_flop_count_sheet.count_sheet_details.each do |d|
        d.counts = [1, 1]
        d.final_count = 1
        d.save!
      end

      flip_flop_count_sheet.complete = true
      flip_flop_count_sheet.save!
      get :show, params: { inventory_reconciliation_id: in_progress_reconciliation.id.to_s, id: flip_flop_count_sheet.id.to_s }
      flip_flop_count_sheet.reload
      expect(flip_flop_count_sheet.items).to_not include(medium_flip_flops)
    end

    it "creates missing misfits when the id is 'misfits'" do
      expect(in_progress_reconciliation.count_sheets.misfits.size).to eq(0)
      get :show, params: { inventory_reconciliation_id: in_progress_reconciliation.id.to_s, id: "misfits" }
      expect(in_progress_reconciliation.count_sheets.misfits.size).to eq(1)
    end

    it "doesn't create misfits when the id is 'misfits' and there is a misfits count sheet" do
      in_progress_reconciliation.find_or_create_misfits_count_sheet
      expect(in_progress_reconciliation.count_sheets.misfits.size).to eq(1)
      get :show, params: { inventory_reconciliation_id: in_progress_reconciliation.id.to_s, id: "misfits" }
      expect(in_progress_reconciliation.count_sheets.misfits.size).to eq(1)
    end
  end

  describe "PUT update" do
    it "allows saving values for the count sheet" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        save: "Save",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        }
      }

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar", "Baz Qux"])
      expect(flip_flop_count_sheet.complete).to be_falsey
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1, 2])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3, 4])
      expect(small_flip_flops_count_sheet_detail.final_count).to be_nil
      expect(large_flip_flops_count_sheet_detail.final_count).to be_nil
    end

    it "allows saving additional columns for the count sheet" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        save: "Save",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        }
      }

      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        save: "Save",
        counter_names: ["Foo Bar", "Baz Qux", "New Counter"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2 3),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4 5)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        }
      }

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar", "Baz Qux", "New Counter"])
      expect(flip_flop_count_sheet.complete).to be_falsey
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1, 2, 3])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3, 4, 5])
      expect(small_flip_flops_count_sheet_detail.final_count).to be_nil
      expect(large_flip_flops_count_sheet_detail.final_count).to be_nil
    end

    it "allows deleting columns for the count sheet by leaving them out" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        save: "Save",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        }
      }

      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        counter_names: ["Foo Bar"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        }
      }

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar"])
      expect(flip_flop_count_sheet.complete).to be_falsey
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3])
      expect(small_flip_flops_count_sheet_detail.final_count).to be_nil
      expect(large_flip_flops_count_sheet_detail.final_count).to be_nil
    end

    it "allows marking the count sheet as completed" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        complete: "Complete",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "5",
          large_flip_flops_count_sheet_detail.id.to_s => "6"
        }
      }

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar", "Baz Qux"])
      expect(flip_flop_count_sheet.complete).to be_truthy
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1, 2])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3, 4])
      expect(small_flip_flops_count_sheet_detail.final_count).to eq(5)
      expect(large_flip_flops_count_sheet_detail.final_count).to eq(6)
    end

    it "blocks marking the count sheet complete if missing final counts" do
      expect do
        put :update, params: {
          id: flip_flop_count_sheet.id.to_s,
          inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
          complete: "Complete",
          counter_names: ["Foo Bar", "Baz Qux"],
          counts: {
            small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
            large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
          },
          final_counts: {
            small_flip_flops_count_sheet_detail.id.to_s => "5",
            large_flip_flops_count_sheet_detail.id.to_s => ""
          }
        }
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "blocks saving the count sheet once it is completed" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        complete: "Complete",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "5",
          large_flip_flops_count_sheet_detail.id.to_s => "6"
        }
      }

      expect do
        put :update, params: {
          id: flip_flop_count_sheet.id.to_s,
          inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
          save: "Save",
          counter_names: ["Foos Bars", "Bazs Quxs"],
          counts: {
            small_flip_flops_count_sheet_detail.id.to_s => %w(3 5),
            large_flip_flops_count_sheet_detail.id.to_s => %w(8 2)
          },
          final_counts: {
            small_flip_flops_count_sheet_detail.id.to_s => "4",
            large_flip_flops_count_sheet_detail.id.to_s => "5"
          }
        }
      end.to raise_error(PermissionError)

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar", "Baz Qux"])
      expect(flip_flop_count_sheet.complete).to be_truthy
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1, 2])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3, 4])
      expect(small_flip_flops_count_sheet_detail.final_count).to eq(5)
      expect(large_flip_flops_count_sheet_detail.final_count).to eq(6)
    end

    it "saves new items for misfits" do
      misfits_count_sheet = in_progress_reconciliation.find_or_create_misfits_count_sheet
      expect(misfits_count_sheet.count_sheet_details.size).to eq(0)

      put :update, params: {
        id: misfits_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        save: "Save",
        counter_names: ["Foos Bars", "Bazs Quxs"],
        new_count_sheet_items: {
          "5" => {
            item_id: small_flip_flops.id.to_s,
            counts: %w(3 4),
            final_count: ""
          },
          "42" => {
            item_id: medium_flip_flops.id.to_s,
            counts: %w(10 12),
            final_count: ""
          }
        }
      }

      misfits_count_sheet.reload
      expect(misfits_count_sheet.count_sheet_details.size).to eq(2)
      expect(misfits_count_sheet.items).to include(small_flip_flops)
      expect(misfits_count_sheet.items).to include(medium_flip_flops)

      small_flip_flop_details = misfits_count_sheet.count_sheet_details.find_by_item_id(small_flip_flops.id)
      medium_flip_flop_details = misfits_count_sheet.count_sheet_details.find_by_item_id(medium_flip_flops.id)
      expect(small_flip_flop_details.counts).to eq([3, 4])
      expect(medium_flip_flop_details.counts).to eq([10, 12])
    end

    it "ignores new items for non-misfits" do
      expect(flip_flop_count_sheet.items).to_not include(medium_flip_flops)

      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        save: "Save",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        },
        new_count_sheet_items: {
          "5" => {
            item_id: medium_flip_flops.id.to_s,
            counts: %w(3 4),
            final_count: ""
          }
        }
      }

      expect(flip_flop_count_sheet.items).to_not include(medium_flip_flops)
    end
  end
end

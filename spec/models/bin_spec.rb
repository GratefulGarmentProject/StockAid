require "rails_helper"

describe Bin, type: :model do
  let(:bin) { bins(:flip_flop_bin) }
  let(:bin_location) { bin_locations(:rack_1_shelf_1) }

  it "should delegate rack to the bin location" do
    expect(bin.rack).to eq("R1")
  end

  it "should delegate shelf to the bin location" do
    expect(bin.shelf).to eq("S1")
  end

  describe "#label_prefix" do
    it "returns the non-numeric prefix of the label" do
      bin.label = "A123"
      expect(bin.label_prefix).to eq("A")
    end
  end

  describe "#label_suffix" do
    it "returns the numeric suffix of the label" do
      bin.label = "RACK42"
      expect(bin.label_suffix).to eq("42")
    end
  end

  describe "#destroy_or_soft_delete!" do
    it "hard-deletes a bin with no references" do
      empty_bin = bins(:empty_bin)
      empty_bin.destroy_or_soft_delete!
      expect(Bin.unscoped.find_by(id: empty_bin.id)).to be_nil
    end

    it "falls back to soft-deleting a bin that's still referenced (e.g. by bin_items/count_sheets)" do
      expect(bin.bin_items).to be_present
      bin.destroy_or_soft_delete!
      expect(bin.reload.deleted_at).to be_present
    end
  end

  describe ".not_deleted" do
    it "excludes soft-deleted bins" do
      result = Bin.not_deleted
      expect(result).not_to include(bins(:deleted_bin))
      expect(result).to include(bins(:flip_flop_bin))
    end
  end

  describe ".for_print_prep" do
    it "returns bins ordered by label" do
      result = Bin.for_print_prep
      expect(result).to be_present
    end
  end

  describe ".to_json" do
    it "returns JSON string" do
      json = Bin.to_json
      expect(json).to be_a(String)
      parsed = JSON.parse(json)
      expect(parsed).to be_an(Array)
    end
  end

  describe ".generate_label" do
    it "generates a label with explicit suffix" do
      params = ActionController::Parameters.new(label_prefix: "BIN", label_suffix: "42")
      expect(Bin.generate_label(params)).to eq("BIN42")
    end

    it "generates next sequential label when no suffix given" do
      params = ActionController::Parameters.new(label_prefix: "ZTEST")
      label = Bin.generate_label(params)
      expect(label).to start_with("ZTEST")
    end

    it "raises when prefix is blank" do
      params = ActionController::Parameters.new(label_prefix: "")
      expect { Bin.generate_label(params) }.to raise_error(RuntimeError, /Prefix is required/)
    end
  end

  describe ".next_label_with_prefix with matching bins" do
    it "returns the next sequential label for an existing prefix pattern" do
      result = Bin.next_label_with_prefix("An Empty Bin ")
      expect(result).to eq("An Empty Bin 2")
    end
  end

  describe ".create_bin!" do
    it "creates a new bin with an existing location" do
      params = ActionController::Parameters.new(
        selected_bin_location: bin_location.id.to_s,
        label_prefix: "ZSPEC",
        label_suffix: "1"
      )
      expect { Bin.create_bin!(params) }.to change(Bin, :count).by(1)
      expect(Bin.find_by(label: "ZSPEC1")).to be_present
    end

    it "creates a bin with items when bin_items param is present" do
      item = items(:small_flip_flops)
      params = ActionController::Parameters.new(
        selected_bin_location: bin_location.id.to_s,
        label_prefix: "ZITEM",
        label_suffix: "1",
        bin_items: { item_id: [item.id.to_s] }
      )
      Bin.create_bin!(params)
      new_bin = Bin.find_by(label: "ZITEM1")
      expect(new_bin.bin_items.count).to eq(1)
    end
  end

  describe ".update_bin!" do
    let(:updatable_bin) { bins(:empty_bin) }

    it "updates the label and location" do
      params = ActionController::Parameters.new(
        id: updatable_bin.id,
        selected_bin_location: bin_location.id.to_s,
        label_prefix: "ZUPD",
        label_suffix: "1"
      )
      Bin.update_bin!(params)
      expect(updatable_bin.reload.label).to eq("ZUPD1")
    end

    it "removes existing items not in the updated item list" do
      flip_flop_bin = bins(:flip_flop_bin)
      expect(flip_flop_bin.bin_items.count).to eq(2)
      params = ActionController::Parameters.new(
        id: flip_flop_bin.id,
        selected_bin_location: bin_location.id.to_s,
        label_prefix: "ZDEL",
        label_suffix: "1"
      )
      Bin.update_bin!(params)
      expect(flip_flop_bin.reload.bin_items.count).to eq(0)
    end
  end
end

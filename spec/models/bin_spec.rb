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
  end
end

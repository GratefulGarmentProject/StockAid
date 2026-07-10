require "rails_helper"

describe BinLocation, type: :model do
  let(:location) { bin_locations(:empty_bin_location) }

  describe ".create_or_find_bin_location" do
    it "finds an existing location when an id is given" do
      params = ActionController::Parameters.new(selected_bin_location: location.id.to_s)
      found = BinLocation.create_or_find_bin_location(params)
      expect(found).to eq(location)
    end

    it "creates a new location when 'new' is given" do
      params = ActionController::Parameters.new(selected_bin_location: "new", rack: "Z", shelf: "99")
      expect do
        BinLocation.create_or_find_bin_location(params)
      end.to change(BinLocation, :count).by(1)
    end

    it "raises when selected_bin_location is blank" do
      params = ActionController::Parameters.new(selected_bin_location: "")
      expect { BinLocation.create_or_find_bin_location(params) }.to raise_error(RuntimeError, /Missing/)
    end
  end

  describe "#deletable?" do
    it "returns true when no bins are present" do
      expect(location.deletable?).to be true
    end

    it "returns false when bins are present" do
      location_with_bins = bin_locations(:rack_1_shelf_1)
      expect(location_with_bins.deletable?).to be false
    end
  end

  describe "#display" do
    it "shows rack and shelf when both are present" do
      location.update!(rack: "A", shelf: "1")
      expect(location.display).to include("Rack A").and include("Shelf 1")
    end

    it "shows only rack when shelf is blank" do
      location.update!(rack: "B", shelf: "")
      expect(location.display).to eq("Rack B")
    end
  end
end

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

  describe ".update_bin_location!" do
    it "updates the rack and shelf" do
      params = ActionController::Parameters.new(id: location.id.to_s, rack: "ZRACK", shelf: "ZSHELF")
      BinLocation.update_bin_location!(params)
      expect(location.reload.rack).to eq("ZRACK")
      expect(location.reload.shelf).to eq("ZSHELF")
    end

    it "raises when the new rack and shelf collide with another active location" do
      other = bin_locations(:rack_1_shelf_1)
      params = ActionController::Parameters.new(id: location.id.to_s, rack: other.rack, shelf: other.shelf)
      expect { BinLocation.update_bin_location!(params) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "#move_all_bins_to!" do
    it "moves all non-deleted bins to the destination location" do
      source = bin_locations(:rack_1_shelf_1)
      destination = bin_locations(:empty_bin_location)
      bin_ids = source.bins.pluck(:id)
      expect(bin_ids).to_not be_empty

      source.move_all_bins_to!(destination)

      expect(Bin.where(id: bin_ids).pluck(:bin_location_id).uniq).to eq([destination.id])
    end

    it "leaves soft-deleted bins at the source untouched" do
      source = bin_locations(:rack_1_shelf_1)
      destination = bin_locations(:empty_bin_location)
      deleted = bins(:deleted_bin)

      source.move_all_bins_to!(destination)

      expect(deleted.reload.bin_location_id).to eq(source.id)
    end

    it "is a no-op when the destination is the same location" do
      source = bin_locations(:rack_1_shelf_1)
      bin_ids = source.bins.pluck(:id)

      source.move_all_bins_to!(source)

      expect(Bin.where(id: bin_ids).pluck(:bin_location_id).uniq).to eq([source.id])
    end
  end

  describe "uniqueness of rack + shelf" do
    it "does not allow two active locations with the same rack and shelf" do
      duplicate = BinLocation.new(rack: location.rack, shelf: location.shelf)
      expect(duplicate).to_not be_valid
      expect(duplicate.errors[:rack]).to be_present
    end

    it "allows a rack and shelf to be reused once the original location is soft-deleted" do
      location.soft_delete
      duplicate = BinLocation.new(rack: location.rack, shelf: location.shelf)
      expect(duplicate).to be_valid
    end
  end

  describe ".not_deleted / .deleted" do
    it "excludes soft-deleted locations from .not_deleted and includes them in .deleted" do
      location.soft_delete
      expect(BinLocation.not_deleted).to_not include(location)
      expect(BinLocation.deleted).to include(location)
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

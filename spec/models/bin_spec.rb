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
end

require "rails_helper"

describe County, type: :model do
  describe ".for_organizations" do
    it "includes all and org counties" do
      results = County.for_organizations
      expect(results.map(&:allowed_for)).to all(be_in(%w[all org]))
    end
  end

  describe ".for_donors" do
    it "includes all and donor counties" do
      results = County.for_donors
      expect(results.map(&:allowed_for)).to all(be_in(%w[all donor]))
    end
  end

  describe ".select_options" do
    it "returns name/id pairs ordered by name" do
      options = County.select_options
      expect(options).to be_an(Array)
      expect(options.first.size).to eq(2)
    end
  end

  describe "#allowed_for_label" do
    it "returns 'Anything' for all" do
      county = County.new(name: "Test", allowed_for: "all")
      expect(county.allowed_for_label).to eq("Anything")
    end

    it "returns 'Organizations Only' for org" do
      county = County.new(name: "Test", allowed_for: "org")
      expect(county.allowed_for_label).to eq("Organizations Only")
    end

    it "returns 'Donors Only' for donor" do
      county = County.new(name: "Test", allowed_for: "donor")
      expect(county.allowed_for_label).to eq("Donors Only")
    end
  end

  describe ".allowed_for_select_options" do
    it "returns the three options" do
      options = County.allowed_for_select_options
      labels = options.map(&:first)
      expect(labels).to include("Anything", "Organizations Only", "Donors Only")
    end
  end
end

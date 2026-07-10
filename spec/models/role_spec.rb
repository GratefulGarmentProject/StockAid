require "rails_helper"

describe Role do
  describe "#to_i" do
    it "returns 3 for root" do
      expect(Role.new("root").to_i).to eq(3)
    end

    it "returns 2 for admin" do
      expect(Role.new("admin").to_i).to eq(2)
    end

    it "returns 1 for report" do
      expect(Role.new("report").to_i).to eq(1)
    end

    it "returns 0 for none" do
      expect(Role.new("none").to_i).to eq(0)
    end

    it "raises for unknown role values" do
      expect { Role.new("superuser").to_i }.to raise_error(RuntimeError, /Unknown role/)
    end
  end

  describe "#<=>" do
    it "correctly orders roles" do
      expect(Role.new("root")).to be > Role.new("admin")
      expect(Role.new("admin")).to be > Role.new("report")
      expect(Role.new("report")).to be > Role.new("none")
    end
  end
end

require "rails_helper"

describe Category, type: :model do
  describe "#increment_next_sku" do
    it "returns the current next_sku and increments it" do
      category = categories(:flip_flops)
      original = category.next_sku
      result = category.increment_next_sku
      expect(result).to eq(original)
      expect(category.reload.next_sku).to eq(original + 1)
    end
  end
end

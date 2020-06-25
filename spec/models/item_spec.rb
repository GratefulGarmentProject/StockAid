require "rails_helper"

describe Item do
  describe ".for_category" do
    it "returns items for_category" do
      category = categories(:flip_flops)
      expect(Item.unscoped.where(category_id: category.id).count).to eq(4)
      flip_flop_items = Item.for_category(category.id)
      expect(flip_flop_items.count).to eq(3)
    end
    it "returns all items if no category is given exists" do
      expect(Item.count).to eq(6)

      expect(Item.for_category(nil).count).to eq(6)
    end
  end
end

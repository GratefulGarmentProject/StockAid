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

  describe ".program_ratio_split_for" do
    let(:item) { items(:large_flip_flops) }
    let(:resource_closets) { programs(:resource_closets) }
    let(:pack_it_forward) { programs(:pack_it_forward) }
    let(:dress_for_dignity) { programs(:dress_for_dignity) }
    let(:beautification_projects) { programs(:beautification_projects) }

    it "splits evenly if all programs are included" do
      ratios = item.program_ratio_split_for([resource_closets, pack_it_forward, dress_for_dignity])
      expect(ratios[resource_closets]).to eq(0.5)
      expect(ratios[pack_it_forward]).to eq(0.25)
      expect(ratios[dress_for_dignity]).to eq(0.25)
    end

    it "doesn't include split for programs not part of the ratios" do
      ratios = item.program_ratio_split_for([resource_closets, pack_it_forward, dress_for_dignity, beautification_projects])
      expect(ratios).to have_key(resource_closets)
      expect(ratios).to have_key(pack_it_forward)
      expect(ratios).to have_key(dress_for_dignity)
      expect(ratios).to_not have_key(beautification_projects)
    end

    it "adjusts split when programs are missing" do
      ratios = item.program_ratio_split_for([pack_it_forward, dress_for_dignity])
      expect(ratios).to_not have_key(resource_closets)
      expect(ratios[pack_it_forward]).to eq(0.5)
      expect(ratios[dress_for_dignity]).to eq(0.5)

      ratios = item.program_ratio_split_for([resource_closets, pack_it_forward])
      expect(ratios).to_not have_key(dress_for_dignity)
      expect(ratios[resource_closets]).to be_within(0.0000000001).of(2 / 3.0)
      expect(ratios[pack_it_forward]).to be_within(0.0000000001).of(1 / 3.0)
    end

    it "uses the ratios as is if none of the programs are included" do
      ratios = item.program_ratio_split_for([beautification_projects])
      expect(ratios).to_not have_key(beautification_projects)
      expect(ratios[resource_closets]).to eq(0.5)
      expect(ratios[pack_it_forward]).to eq(0.25)
      expect(ratios[dress_for_dignity]).to eq(0.25)
    end
  end
end

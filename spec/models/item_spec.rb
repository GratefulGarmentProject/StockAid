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

  describe "#current_total_value" do
    it "returns quantity times value" do
      item = items(:small_flip_flops)
      expect(item.current_total_value).to eq(item.current_quantity * item.value)
    end

    it "returns nil when value is nil" do
      item = items(:small_flip_flops)
      item.value = nil
      expect(item.current_total_value).to be_nil
    end
  end

  describe "#requested_quantity and #available_quantity" do
    it "raises unless requested_quantity is loaded" do
      item = items(:small_flip_flops)
      expect { item.requested_quantity }.to raise_error(RuntimeError)
    end

    it "returns available quantity when requested_quantity is set" do
      item = items(:small_flip_flops)
      item.instance_variable_set(:@requested_quantity, 2)
      expect(item.available_quantity).to eq(item.current_quantity - 2)
    end
  end

  describe "#pending_orders" do
    it "returns orders in pending status" do
      item = items(:small_flip_flops)
      result = item.pending_orders
      expect(result).to be_an(ActiveRecord::Relation)
    end
  end

  describe "#mark_event" do
    it "returns early when params are missing" do
      item = items(:small_flip_flops)
      original_qty = item.current_quantity
      item.mark_event({})
      expect(item.current_quantity).to eq(original_qty)
    end

    it "updates quantity when all params are present" do
      item = items(:small_flip_flops)
      original_qty = item.current_quantity
      item.mark_event(edit_amount: "5", edit_method: "add", edit_reason: "adjustment", edit_source: "test")
      item.save!
      expect(item.reload.current_quantity).to eq(original_qty + 5)
    end
  end

  describe "#relevant_history?" do
    it "returns true for bulk_pricing_change" do
      item = items(:small_flip_flops)
      version = double(edit_reason: "bulk_pricing_change", changeset: {})
      expect(item.relevant_history?(version)).to eq(true)
    end

    it "returns truthy when current_quantity changed" do
      item = items(:small_flip_flops)
      version = double(edit_reason: "adjustment", changeset: { "current_quantity" => [1, 2] })
      expect(item.relevant_history?(version)).to be_truthy
    end

    it "returns falsey for irrelevant changes" do
      item = items(:small_flip_flops)
      version = double(edit_reason: "other", changeset: { "notes" => %w[a b] })
      expect(item.relevant_history?(version)).to be_falsey
    end
  end

  describe "#soft_delete and #restore" do
    it "soft deletes and marks item as deleted" do
      item = items(:small_flip_flops)
      item.soft_delete
      expect(item.reload.deleted?).to eq(true)
    end

    it "restores a soft-deleted item" do
      item = items(:small_flip_flops)
      item.soft_delete
      item.restore
      expect(item.reload.deleted?).to eq(false)
    end
  end

  describe "#deleted and .not_deleted" do
    it ".deleted returns only deleted items" do
      item = items(:small_flip_flops)
      item.soft_delete
      expect(Item.unscoped.deleted).to include(item)
    end

    it ".not_deleted excludes deleted items" do
      item = items(:small_flip_flops)
      item.soft_delete
      expect(Item.unscoped.not_deleted).not_to include(item)
    end
  end

  describe "#total_value" do
    it "returns current_total_value when no time provided" do
      item = items(:small_flip_flops)
      expect(item.total_value).to eq(item.current_total_value)
    end

    it "returns current_total_value when at time is recent" do
      item = items(:small_flip_flops)
      expect(item.total_value(at: Time.zone.now)).to eq(item.current_total_value)
    end
  end

  describe "#each_history_version" do
    it "yields nothing when no relevant versions exist" do
      item = items(:small_flip_flops)
      versions_seen = []
      item.each_history_version { |v, _name| versions_seen << v }
      expect(versions_seen).to be_empty
    end

    it "yields version and user name after a quantity change" do
      item = items(:small_flip_flops)
      PaperTrail.request.whodunnit = users(:root).id.to_s
      item.mark_event(edit_amount: "3", edit_method: "add", edit_reason: "adjustment", edit_source: "spec")
      item.save!

      versions_seen = []
      item.each_history_version { |v, name| versions_seen << [v, name] }
      expect(versions_seen.length).to be >= 1
      expect(versions_seen.first[1]).to be_a(String)
    end

    it "uses 'System' as user name when whodunnit is blank" do
      item = items(:small_flip_flops)
      PaperTrail.request.whodunnit = nil
      item.mark_event(edit_amount: "1", edit_method: "add", edit_reason: "adjustment", edit_source: "spec")
      item.save!

      versions_seen = []
      item.each_history_version { |v, name| versions_seen << [v, name] }
      expect(versions_seen.any? { |_v, name| name == "System" }).to eq(true)
    end

    it "uses 'Unknown' as user name when whodunnit references a missing user" do
      item = items(:small_flip_flops)
      PaperTrail.request.whodunnit = "99999999"
      item.mark_event(edit_amount: "1", edit_method: "add", edit_reason: "adjustment", edit_source: "spec")
      item.save!

      versions_seen = []
      item.each_history_version { |v, name| versions_seen << [v, name] }
      expect(versions_seen.any? { |_v, name| name.start_with?("Unknown") }).to eq(true)
    end
  end

  describe "#update_quantity with new_total" do
    it "sets current_quantity to the given amount" do
      item = items(:small_flip_flops)
      item.mark_event(edit_amount: "42", edit_method: "new_total", edit_reason: "adjustment", edit_source: "spec")
      item.save!
      expect(item.reload.current_quantity).to eq(42)
    end
  end
end

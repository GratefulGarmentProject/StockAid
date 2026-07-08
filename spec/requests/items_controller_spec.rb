require "rails_helper"

RSpec.describe ItemsController, type: :request do
  let(:user) { users(:root) }
  let(:non_super_user) { users(:acme_root) }

  before do
    sign_in(user)
  end

  describe "#index" do
    it "renders ok" do
      get items_path
      expect(response).to have_http_status(:ok)
    end

    it "renders ok with a category filter" do
      get items_path, params: { category_id: categories(:flip_flops).id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_item_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#edit" do
    it "renders ok" do
      get edit_item_path(items(:small_flip_flops))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#edit_stock" do
    it "renders ok" do
      get edit_stock_item_path(items(:small_flip_flops))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates an item and redirects" do
      # assign_sku generates a SKU from fixture category IDs that overflow 4-byte integers
      allow_any_instance_of(Item).to receive(:assign_sku) { |item| item.sku = 99990001 }
      post items_path, params: {
        item: {
          description: "New Test Item",
          category_id: categories(:flip_flops).id,
          value: "5.00",
          item_program_ratio_id: item_program_ratios(:all_resource_closets).id
        }
      }
      expect(response).to redirect_to(items_path(category_id: categories(:flip_flops).id))
      expect(flash[:success]).to be_present
      expect(Item.find_by(description: "New Test Item")).to be_present
    end
  end

  describe "#update" do
    let(:item) { items(:small_flip_flops) }

    it "updates the item and redirects" do
      patch item_path(item), params: {
        item: {
          description: item.description,
          current_quantity: "45",
          category_id: item.category_id,
          value: "12.15",
          item_program_ratio_id: item.item_program_ratio_id,
          edit_amount: "3",
          edit_method: "add",
          edit_reason: "adjustment",
          edit_source: "test"
        }
      }
      expect(response).to redirect_to(items_path(category_id: item.category_id))
      expect(flash[:success]).to be_present
    end
  end

  describe "#destroy" do
    let(:item) { items(:medium_flip_flops) }

    it "soft deletes the item and redirects" do
      delete item_path(item)
      expect(response).to have_http_status(:found)
      expect(item.reload.deleted_at).to be_present
    end
  end

  describe "#restore" do
    let(:item) { items(:deleted_flip_flops) }

    it "restores the item and redirects" do
      patch restore_item_path(item)
      expect(response).to have_http_status(:found)
    end
  end

  describe "#deleted" do
    it "renders ok" do
      get deleted_items_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#bulk_pricing" do
    it "can render ok" do
      get "/inventory/bulk_pricing"
      expect(response).to have_http_status(:ok)
    end

    context "with a user without access" do
      let(:user) { non_super_user }

      it "prevents access" do
        expect do
          get "/inventory/bulk_pricing"
        end.to raise_error(PermissionError)
      end
    end
  end

  describe "#update_bulk_pricing" do
    let(:item_1) { items(:small_flip_flops) }
    let(:item_2) { items(:medium_flip_flops) }
    let(:item_3) { items(:large_flip_flops) }
    let(:item_4) { items(:small_pants) }

    let(:item_1_new_value) { item_1.value + 0.42 }
    let(:item_2_new_value) { item_2.value + 1.00 }
    let(:item_3_new_value) { item_3.value }
    let(:item_4_new_value) { item_4.value + 0.01 }

    let!(:item_1_version_count) { item_1.versions.count }
    let!(:item_2_version_count) { item_2.versions.count }
    let!(:item_3_version_count) { item_3.versions.count }
    let!(:item_4_version_count) { item_4.versions.count }

    let(:params) do
      {
        values: {
          item_1.id => item_1_new_value,
          item_2.id => item_2_new_value,
          item_3.id => item_3_new_value,
          item_4.id => item_4_new_value
        }
      }
    end

    it "updates changed values with a history record" do
      post "/inventory/update_bulk_pricing", params: params
      expect(response).to redirect_to(bulk_pricing_items_path)
      item_1.reload
      item_2.reload
      item_4.reload
      expect(item_1.value).to eq(item_1_new_value)
      expect(item_2.value).to eq(item_2_new_value)
      expect(item_4.value).to eq(item_4_new_value)
      expect(item_1.versions.count).to eq(item_1_version_count + 1)
      expect(item_2.versions.count).to eq(item_2_version_count + 1)
      expect(item_4.versions.count).to eq(item_4_version_count + 1)

      item_1_version = item_1.versions.last
      expect(item_1_version.edit_reason).to eq("bulk_pricing_change")
      expect(item_1_version.edit_source).to start_with("Bulk pricing updated with ID")

      item_2_version = item_2.versions.last
      expect(item_2_version.edit_reason).to eq("bulk_pricing_change")
      expect(item_2_version.edit_source).to eq(item_1_version.edit_source)

      item_4_version = item_4.versions.last
      expect(item_4_version.edit_reason).to eq("bulk_pricing_change")
      expect(item_4_version.edit_source).to eq(item_1_version.edit_source)
    end

    it "doesn't update unchanged values nor adds a history record" do
      original_value = item_3.value
      post "/inventory/update_bulk_pricing", params: params
      expect(response).to redirect_to(bulk_pricing_items_path)
      item_3.reload
      expect(item_3.value).to eq(original_value)
      expect(item_3.versions.count).to eq(item_3_version_count)
    end

    context "with a user without access" do
      let(:user) { non_super_user }

      it "prevents access" do
        expect do
          post "/inventory/update_bulk_pricing", params: params
        end.to raise_error(PermissionError)
      end
    end
  end
end

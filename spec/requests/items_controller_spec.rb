require "rails_helper"

RSpec.describe ItemsController, type: :request do
  let(:user) { users(:root) }
  let(:non_super_user) { users(:acme_root) }

  before do
    sign_in(user)
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

require "rails_helper"

RSpec.describe ItemProgramRatiosController, type: :request do
  let(:super_admin) { users(:root) }
  let(:ratio) { item_program_ratios(:all_resource_closets) }

  before { sign_in super_admin }

  def program_ratio_params
    # All programs must be in the hash; values must sum to 100
    all_programs = Program.all.to_a
    all_programs.each_with_index.each_with_object({}) do |(prog, i), h|
      h[prog.id.to_s] = i == 0 ? "100" : "0"
    end
  end

  describe "#index" do
    it "renders ok" do
      get item_program_ratios_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_item_program_ratio_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#edit" do
    it "renders ok" do
      get edit_item_program_ratio_path(ratio)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a ratio and redirects" do
      post item_program_ratios_path, params: {
        item_program_ratio: {
          name: "Test Ratio",
          program_ratio: program_ratio_params
        }
      }
      expect(response).to redirect_to(item_program_ratios_path)
      expect(flash[:success]).to be_present
      expect(ItemProgramRatio.find_by(name: "Test Ratio")).to be_present
    end
  end

  describe "#update" do
    it "updates and redirects" do
      patch item_program_ratio_path(ratio), params: {
        item_program_ratio: {
          name: "Updated Ratio",
          program_ratio: program_ratio_params
        }
      }
      expect(response).to redirect_to(item_program_ratios_path)
      expect(flash[:success]).to be_present
      expect(ratio.reload.name).to eq("Updated Ratio")
    end
  end

  describe "#destroy" do
    let!(:empty_ratio) do
      r = ItemProgramRatio.new(name: "Empty Ratio For Deletion")
      r.update_program_ratios(program_ratio_params)
      r.save!
      r.items.clear
      r
    end

    it "deletes an empty ratio and redirects" do
      delete item_program_ratio_path(empty_ratio)
      expect(response).to redirect_to(item_program_ratios_path)
      expect(flash[:success]).to be_present
      expect(ItemProgramRatio.find_by(id: empty_ratio.id)).to be_nil
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get item_program_ratios_path }.to raise_error(PermissionError)
    end
  end
end

require "rails_helper"

RSpec.describe CategoriesController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#new" do
    it "renders ok" do
      get new_category_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#edit" do
    it "renders ok" do
      get edit_category_path(categories(:flip_flops))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a category and redirects" do
      post categories_path, params: { category: { description: "New Test Category" } }
      expect(response).to redirect_to(items_path)
      expect(flash[:success]).to be_present
      expect(Category.find_by(description: "New Test Category")).to be_present
    end
  end

  describe "#update" do
    let(:category) { categories(:flip_flops) }

    it "updates and redirects" do
      patch category_path(category), params: { category: { description: "Updated Flip Flops" } }
      expect(response).to redirect_to(items_path(category_id: category.id))
      expect(category.reload.description).to eq("Updated Flip Flops")
    end
  end

  describe "#destroy" do
    context "a category with no items" do
      let!(:empty_category) { Category.create!(description: "Empty Test Category") }

      it "destroys and redirects" do
        delete category_path(empty_category)
        expect(response).to redirect_to(items_path)
        expect(flash[:success]).to be_present
        expect(Category.find_by(id: empty_category.id)).to be_nil
      end
    end

    context "a category with items" do
      let(:category) { categories(:pants) }
      let(:item) { items(:small_pants) }

      it "moves items to unknown category before destroying" do
        delete category_path(category)
        expect(response).to redirect_to(items_path)
        expect(item.reload.category.description).to eq("Unknown")
      end
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get new_category_path }.to raise_error(PermissionError)
    end
  end
end

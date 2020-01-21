require "rails_helper"

describe ItemsController, type: :controller do
  let(:category1)    { categories(:flip_flops) }
  let(:category2)    { categories(:pants) }
  let(:item1)        { items(:small_flip_flops) }
  let(:item2)        { items(:large_flip_flops) }
  let(:deleted_item) { items(:deleted_flip_flops) }
  let(:item3)        { items(:small_pants) }
  let(:item4)        { items(:small_pants) }

  describe "GET#index" do
    it "returns the correct variables" do
      signed_in_user :root

      get :index, params: { category_id: category1.id }

      expect(assigns(:category)).to   eq(category1)
      expect(assigns(:items)).to      include(item1, item2)
      expect(assigns(:categories)).to include(category1, category2)
    end

    context "when there are deleted items in the category" do
      it "does not include deleted items" do
        signed_in_user :root
        item1.soft_delete

        get :index, params: { category_id: category1.id }

        expect(assigns(:category)).to   eq(category1)
        expect(assigns(:items)).to      include(item2)
        expect(assigns(:categories)).to include(category1, category2)
      end
    end
  end

  describe "GET#deleted items" do
    it "returns the correct items" do
      signed_in_user :root

      get :deleted

      expect(assigns(:items)).to eq([deleted_item])
      expect(assigns(:categories)).to include(category1, category2)
    end
  end
end

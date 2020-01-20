require "rails_helper"

describe CategoriesController, type: :controller do
  let(:category)     { categories(:flip_flops) }
  let(:unknown_cat)  { categories(:unknown) }
  let(:item)         { items(:small_flip_flops) }
  let(:deleted_item) { items(:deleted_flip_flops) }

  describe "DELETE#destroy" do
    it "does _not_ leave items associated to nonexisting categories" do
      signed_in_user :root

      delete :destroy, params: { id: category.id }

      expect(item.category).to eq(unknown_cat)
      expect(deleted_item.category).to eq(unknown_cat)
    end
  end
end

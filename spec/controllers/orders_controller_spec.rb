require "rails_helper"

describe OrdersController, type: :controller do
  let(:foo_inc) { organizations(:foo_inc) }
  let(:foo_inc_normal) { users(:foo_inc_normal) }

  describe "POST create from select_items" do
    let(:valid_order_params) {
      {
        order: {
          organization_id: foo_inc.id.to_s,
          order_details: {
            item_id: [items(:underwear_men_s).id.to_s],
            quantity: [3]
          }
        }
      }
    }

    let(:invalid_organization_params) {
      {
        order: {
          organization_id: "999999",
          order_details: {
            item_id: [items(:underwear_men_s).id.to_s],
            quantity: ["3"]
          }
        }
      }
    }

    let(:excessive_quantity_params) {
      {
        order: {
          organization_id: foo_inc_normal.organizations.first.id.to_s,
          order_details: {
            item_id: [items(:underwear_men_s).id.to_s],
            quantity: ["999999"]
          }
        }
      }
    }

    let(:zero_quantity_params) {
      {
        order: {
          organization_id: foo_inc_normal.organizations.first.id.to_s,
          order_details: {
            item_id: [items(:underwear_men_s).id.to_s],
            quantity: ["0"]
          }
        }
      }
    }

    let(:negative_quantity_params) {
      {
        order: {
          organization_id: foo_inc_normal.organizations.first.id.to_s,
          order_details: {
            item_id: [items(:underwear_men_s).id.to_s],
            quantity: ["-1"]
          }
        }
      }
    }

    let(:duplicate_items_params) {
      {
        order: {
          organization_id: foo_inc_normal.organizations.first.id.to_s,
          order_details: {
            item_id: [items(:underwear_men_s).id.to_s, items(:underwear_men_s).id.to_s],
            quantity: ["1", "2"]
          }
        }
      }
    }

    let(:partial_details_params) {
      {
        order: {
          organization_id: foo_inc_normal.organizations.first.id.to_s,
          order_details: {
            item_id: [items(:underwear_men_s).id.to_s],
            quantity: []
          }
        }
      }
    }

    it "creates an order assigned to the selected organization" do
      signed_in_user :foo_inc_normal
      post :create, valid_order_params
      order = Order.first

      expect(order.organization_id).to eq(foo_inc.id)
    end

    it "fails if user isn't affiliated with selected organization" do
      expect do
        signed_in_user :acme_normal
        post :create, valid_order_params
      end.to raise_error(PermissionError)
    end

    it "fails if organization doesn't exist" do
      expect do
        signed_in_user :foo_inc_normal
        post :create, invalid_organization_params
      end.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "creates an order_details containing the correct item and quantity" do
      signed_in_user :foo_inc_normal
      post :create, valid_order_params
      order = Order.first

      expect(order.user_id).to eq(foo_inc_normal.id)
      expect(order.order_details.first.item_id).to eq(items(:underwear_men_s).id)
      expect(order.order_details.first.quantity).to eq(3)
    end

    it "fails if the quantity of an item requested is greater than available" do
      expect do
        signed_in_user :foo_inc_normal
        post :create, excessive_quantity_params
      end.to raise_error(InvalidOrderDetailsError)
    end

    it "fails if the quantity of an item requested is 0" do
      expect do
        signed_in_user :foo_inc_normal
        post :create, zero_quantity_params
      end.to raise_error(InvalidOrderDetailsError)
    end

    it "fails if the quantity of an item requested is negative" do
      expect do
        signed_in_user :foo_inc_normal
        post :create, negative_quantity_params
      end.to raise_error(InvalidOrderDetailsError)
    end

    it "fails if the same item is requested multiple times" do
      expect do
        signed_in_user :foo_inc_normal
        post :create, duplicate_items_params
      end.to raise_error(InvalidOrderDetailsError)
    end

    it "fails if there is a partial order detail" do
      expect do
        signed_in_user :foo_inc_normal
        post :create, partial_details_params
      end.to raise_error(InvalidOrderDetailsError)
    end
  end

  describe "PUT update from select_items" do
  end
end

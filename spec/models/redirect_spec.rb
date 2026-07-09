require "rails_helper"

describe PermissionError do
  describe ".to" do
    let(:url_helpers) { Rails.application.routes.url_helpers }
    let(:orders_path) { url_helpers.orders_path }
    let(:edit_order_path) { url_helpers.edit_order_path(order_id) }
    let(:order_id) { 1337 }

    it "returns the default if return_to is not specified" do
      expect(Redirect.to(orders_path, {}, allow: :category))
        .to eq(orders_path)
      expect(Redirect.to(orders_path, { redirect_to: "" }, allow: :category))
        .to eq(orders_path)
    end

    it "returns the orders_path for orders" do
      expect(Redirect.to("/fake/path", { redirect_to: "orders" }, allow: :orders))
        .to eq(orders_path)
    end

    it "returns the edit_order_path(id) for order and id" do
      expect(Redirect.to("/fake/path", { redirect_to: "order", redirect_id: order_id }, allow: :order))
        .to eq(edit_order_path)
    end

    it "fails when the requested redirect is not allowed" do
      expect { Redirect.to("/fake/path", { redirect_to: "orders" }, allow: :category) }
        .to raise_error(Redirect::NotAllowedError)
    end

    it "fails when the requested redirect is allowed but is missing the needed id" do
      expect { Redirect.to("/fake/path", { redirect_to: "order" }, allow: :order) }
        .to raise_error(Redirect::MissingIdError)
      expect { Redirect.to("/fake/path", { redirect_to: "order", redirect_id: "" }, allow: :order) }
        .to raise_error(Redirect::MissingIdError)
    end

    it "fails when the requested redirect is allowed but hasn't been implimented yet" do
      expect { Redirect.to("/fake/path", { redirect_to: "not_implimented" }, allow: :not_implimented) }
        .to raise_error(Redirect::NotImplimentedError)
    end

    it "returns items_path for inventory" do
      expect(Redirect.to("/fake/path", { redirect_to: "inventory" }, allow: :inventory))
        .to eq(url_helpers.items_path)
    end

    it "returns new_purchase_path for new_purchase" do
      expect(Redirect.to("/fake/path", { redirect_to: "new_purchase" }, allow: :new_purchase))
        .to eq(url_helpers.new_purchase_path)
    end

    it "returns edit_organization_path for organization with id" do
      org_id = organizations(:acme).id
      expect(Redirect.to("/fake/path", { redirect_to: "organization", redirect_id: org_id }, allow: :organization))
        .to eq(url_helpers.edit_organization_path(org_id))
    end

    it "returns organizations_path for organizations" do
      expect(Redirect.to("/fake/path", { redirect_to: "organizations" }, allow: :organizations))
        .to eq(url_helpers.organizations_path)
    end

    it "returns deleted_organizations_path for organizations_deleted" do
      expect(Redirect.to("/fake/path", { redirect_to: "organizations_deleted" }, allow: :organizations_deleted))
        .to eq(url_helpers.deleted_organizations_path)
    end

    it "returns edit_user_path for user with id" do
      user_id = users(:root).id
      expect(Redirect.to("/fake/path", { redirect_to: "user", redirect_id: user_id }, allow: :user))
        .to eq(url_helpers.edit_user_path(user_id))
    end

    it "returns users_path for users" do
      expect(Redirect.to("/fake/path", { redirect_to: "users" }, allow: :users))
        .to eq(url_helpers.users_path)
    end

    it "returns edit_vendor_path for vendor with id" do
      vendor_id = vendors(:guinan).id
      expect(Redirect.to("/fake/path", { redirect_to: "vendor", redirect_id: vendor_id }, allow: :vendor))
        .to eq(url_helpers.edit_vendor_path(vendor_id))
    end

    it "returns vendors_path for vendors" do
      expect(Redirect.to("/fake/path", { redirect_to: "vendors" }, allow: :vendors))
        .to eq(url_helpers.vendors_path)
    end
  end
end

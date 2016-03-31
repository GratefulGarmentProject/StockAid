require "rails_helper"

describe PermissionError do
  describe ".to" do
    let(:url_helpers) { Rails.application.routes.url_helpers }
    let(:orders_path) { url_helpers.orders_path }
    let(:order_path) { url_helpers.order_path(order_id) }
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

    it "returns the order_path(id) for order and id" do
      expect(Redirect.to("/fake/path", { redirect_to: "order", redirect_id: order_id }, allow: :order))
        .to eq(order_path)
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
  end
end

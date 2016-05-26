require "rails_helper"

describe Order do
  describe ".value" do
    it "has no value with no details" do
      order = Order.new
      expect(order.value).to eq(0.0)
    end

    it "has no value with details with no value" do
      order = Order.new
      order.order_details.build(quantity: 0, value: 5.0)
      order.order_details.build(quantity: 5, value: 0.0)
      expect(order.value).to eq(0.0)
    end

    it "value equal to all details full value" do
      order = Order.new
      order.order_details.build(quantity: 1, value: 5.0)
      order.order_details.build(quantity: 2, value: 2.0)
      order.order_details.build(quantity: 3, value: 3.0)
      expect(order.value).to eq(18.0)
    end
  end
end

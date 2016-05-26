require "rails_helper"

describe OrderDetail do
  describe ".total_value" do
    it "has no value with no quantity" do
      order_detail = OrderDetail.new quantity: 0, value: 5.0
      expect(order_detail.total_value).to eq(0.0)
    end

    it "has no value with no value" do
      order_detail = OrderDetail.new quantity: 5, value: 0.0
      expect(order_detail.total_value).to eq(0.0)
    end

    it "doesn't change value with a single quantity" do
      order_detail = OrderDetail.new quantity: 1, value: 5.0
      expect(order_detail.total_value).to eq(5.0)
    end

    it "has a larger value with higher quantity" do
      order_detail = OrderDetail.new quantity: 3, value: 5.0
      expect(order_detail.total_value).to eq(15.0)
    end
  end
end

require "rails_helper"

describe OrderDetail do
  describe "#include_in_packing_slip?" do
    it "returns true when quantity is non-zero" do
      detail = OrderDetail.new(quantity: 3, value: 5.0)
      allow(detail).to receive(:requested_quantity).and_return(3)
      expect(detail.include_in_packing_slip?).to be true
    end

    it "returns false when both quantity and requested_quantity are zero" do
      detail = OrderDetail.new(quantity: 0, value: 5.0)
      allow(detail).to receive(:requested_quantity).and_return(0)
      expect(detail.include_in_packing_slip?).to be false
    end
  end

  describe "#requested_differs_from_quantity?" do
    it "returns false when quantity matches requested_quantity" do
      detail = OrderDetail.new(quantity: 3, value: 5.0)
      allow(detail).to receive(:requested_quantity).and_return(3)
      expect(detail.requested_differs_from_quantity?).to be false
    end

    it "returns true when quantity differs from requested_quantity" do
      detail = OrderDetail.new(quantity: 3, value: 5.0)
      allow(detail).to receive(:requested_quantity).and_return(2)
      expect(detail.requested_differs_from_quantity?).to be true
    end
  end

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

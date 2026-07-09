require "rails_helper"

describe TrackingDetail, type: :model do
  let(:order) { orders(:open_order) }

  describe ".valid_carriers" do
    it "returns FedEx, USPS, and UPS (excludes Hand)" do
      carriers = TrackingDetail.valid_carriers
      expect(carriers.keys).to match_array(%w[FedEx USPS UPS])
      expect(carriers.keys).not_to include("Hand")
    end
  end

  describe "#tracking_url" do
    def build_detail(carrier, number = "ABC123")
      TrackingDetail.new(order: order, shipping_carrier: carrier, tracking_number: number)
    end

    it "returns a FedEx tracking URL" do
      detail = build_detail(:FedEx, "1234567890")
      expect(detail.tracking_url).to include("fedex.com")
      expect(detail.tracking_url).to include("1234567890")
    end

    it "returns a USPS tracking URL" do
      detail = build_detail(:USPS, "9400111899223408718698")
      expect(detail.tracking_url).to include("usps.com")
      expect(detail.tracking_url).to include("9400111899223408718698")
    end

    it "returns a UPS tracking URL" do
      detail = build_detail(:UPS, "1Z999AA10123456784")
      expect(detail.tracking_url).to include("ups.com")
      expect(detail.tracking_url).to include("1Z999AA10123456784")
    end

    it "returns 'N/A' for Hand delivery" do
      detail = build_detail(:Hand)
      expect(detail.tracking_url).to eq("N/A")
    end
  end
end

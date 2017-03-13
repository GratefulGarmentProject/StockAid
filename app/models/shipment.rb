class Shipment < ActiveRecord::Base
  belongs_to :order

  enum shipping_carrier: { FedEx: 0, USPS: 1, UPS: 2, Hand: 3 }

  def self.valid_carriers
    shipping_carriers.slice(*%w(FedEx USPS UPS))
  end

  def tracking_url
    case shipping_carrier
    when "FedEx"
      "https://www.fedex.com/apps/fedextrack/?tracknumbers=#{tracking_number}"
    when "USPS"
      "https://tools.usps.com/go/TrackConfirmAction.action?tRef=fullpage&tLc=1&text28777=&tLabels=#{tracking_number}"
    when "UPS"
      "https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=#{tracking_number}&loc=en_us"
    when "Hand"
      "N/A"
    end
  end
end

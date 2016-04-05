class Shipment < ActiveRecord::Base
  belongs_to :order

  enum shipping_carrier: { FedEx: 0, USPS: 1, UPS: 2 }

  def tracking_url
    case shipping_carrier
    when "FedEx"
      "https://www.fedex.com/apps/fedextrack/?tracknumbers=#{tracking_number}"
    when "USPS"
      "https://tools.usps.com/go/TrackConfirmAction.action?tRef=fullpage&tLc=1&text28777=&tLabels=#{tracking_number}"
    when "UPS"
      "https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=#{tracking_number}&loc=en_us"
    end
  end
end

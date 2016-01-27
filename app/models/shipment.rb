class Shipment < ActiveRecord::Base

  validates :shipping_carrier, inclusion: { in: %w(fedex usps ups),
    message: "%{value} is not a valid shipping carrier" }

  def tracking_url
    case shipping_carrier.to_sym
    when :ups 
      "https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=#{self.tracking_number}&loc=en_us"
    when :usps
      "https://tools.usps.com/go/TrackConfirmAction.action?tRef=fullpage&tLc=1&text28777=&tLabels=#{self.tracking_number}"
    when :fedex
      "https://www.fedex.com/apps/fedextrack/?tracknumbers=#{self.tracking_number}"
    end
  end
end

class Donation < ActiveRecord::Base
  belongs_to :donor
  belongs_to :user
  has_many :donation_details

  def self.create_donation!(creator, params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    donor = Donor.create_or_find_donor(params)
    donation_params = params.require(:donation).permit(:notes)
    donation_detail_params = params.require(:donation).require(:donation_details)
    item_params = donation_detail_params.require(:item_id)
    quantity_params = donation_detail_params.require(:quantity)

    donation = Donation.create!(
      donor: donor,
      user: creator,
      notes: donation_params[:notes],
      donation_date: Time.zone.now
    )

    item_params.each_with_index do |item_id, i|
      quantity = quantity_params[i].to_i
      item = Item.find(item_id)

      donation.donation_details.create!(
        item: item,
        quantity: quantity,
        value: item.value
      )
    end
  end
end

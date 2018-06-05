class Donation < ApplicationRecord
  belongs_to :donor
  belongs_to :user
  has_many :donation_details

  def self.for_donor(donor)
    where(donor: donor)
  end

  def self.create_donation!(creator, params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    donor = Donor.create_or_find_donor(params)
    donation_params = params.require(:donation).permit(:notes, :date)
    donation_detail_params = params.require(:donation).require(:donation_details)
    item_params = donation_detail_params.require(:item_id)
    quantity_params = donation_detail_params.require(:quantity)

    donation = Donation.create!(
      donor: donor,
      user: creator,
      notes: donation_params[:notes],
      donation_date: donation_params[:date]
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

  def formatted_donation_date
    donation_date.strftime("%-m/%-d/%Y") if donation_date.present?
  end

  def value
    donation_details.map(&:total_value).sum
  end

  def item_count
    donation_details.map(&:quantity).sum
  end
end

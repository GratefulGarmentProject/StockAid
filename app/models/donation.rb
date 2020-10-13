class Donation < ApplicationRecord
  include SoftDeletable

  belongs_to :donor
  belongs_to :user
  has_many :donation_details

  def self.create_donation!(creator, donor, params)
    donation_params = params.require(:donation).permit(:notes, :date)

    donation = Donation.create!(
      donor: donor,
      user: creator,
      notes: donation_params[:notes],
      donation_date: donation_params[:date]
    )

    donation.add_to_donation!(params, required: true)
    donation
  end

  def update_donation!(params)
    donation_params = params.require(:donation).permit(:notes, :date)
    self.notes = donation_params[:notes]
    self.donation_date = donation_params[:date]
    save!
    add_to_donation!(params)
    self
  end

  def synced?
    external_id.present?
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

  def add_to_donation!(params, required: false)
    return self if skip_adding_donations?(params, required)
    donation_detail_params = params.require(:donation).require(:donation_details)
    item_params = donation_detail_params.require(:item_id)
    quantity_params = donation_detail_params.require(:quantity)

    item_params.each_with_index do |item_id, i|
      quantity = quantity_params[i].to_i
      item = Item.find(item_id)

      donation_details.create!(
        item: item,
        quantity: quantity,
        value: item.value
      )
    end
  end

  private

  def skip_adding_donations?(params, required)
    return false if required
    return true if params.dig(:donation, :donation_details, :item_id).blank?
    false
  end
end

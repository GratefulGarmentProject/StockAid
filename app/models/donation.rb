class Donation
  def self.create_donation!(_creator, params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # TODO: Clean this up once Donation is an ActiveRecord model
    donation_params = params.require(:donation)
    description = []
    description << "from: #{donation_params[:name]}" if donation_params[:name].present?
    description << "address: #{donation_params[:address]}" if donation_params[:address].present?
    description << "email: #{donation_params[:email]}" if donation_params[:email].present?
    description << "notes: #{donation_params[:notes]}" if donation_params[:notes].present?
    description = "Donation #{description.join(', ')}"

    donation_params[:donation_details].fetch(:item_id, []).each_with_index do |item_id, i|
      quantity = donation_params[:donation_details][:quantity][i]
      item = Item.find(item_id)

      item.mark_event(
        edit_amount: quantity,
        edit_method: "add",
        edit_reason: "donation",
        edit_source: description
      )

      item.save!
    end
  end
end

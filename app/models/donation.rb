class Donation
  def self.create_donation!(creator, params)
    donation_params = params.require(:donation)

    donation_params[:donation_details].fetch(:item_id, []).each_with_index do |item_id, i|
      quantity = donation_params[:donation_details][:quantity][i]
      item = Item.find(item_id)
      item.mark_event(
        edit_amount: quantity,
        edit_method: "add",
        edit_reason: "donation",
        edit_source: donation_params[:description]
      )

      item.save!
    end
  end
end

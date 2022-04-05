class OneRevenueStreamPerDonation < ActiveRecord::Migration[5.1]
  def up
    revenue_streams_by_donation_id = OneRevenueStreamPerDonation_RevenueStreamDonations.all.to_a.group_by(&:donation_id)
    multiples = revenue_streams_by_donation_id.values.select { |revenue_stream_donations| revenue_stream_donations.size > 1 }

    if multiples.present?
      donation_ids_with_multiple_revenue_streams = multiples.map(&:first).map(&:donation_id).sort.join(", ")
      raise "Cannot run migration, the following donations have multiple revenue streams: [#{donation_ids_with_multiple_revenue_streams}]"
    end

    add_reference :donations, :revenue_stream, index: true

    revenue_streams_by_donation_id.each do |donation_id, revenue_streams|
      Donation.where(id: donation_id).update_all(revenue_stream_id: revenue_streams.first.revenue_stream_id)
    end

    drop_table :revenue_stream_donations
  end

  def down
    create_table :revenue_stream_donations do |t|
      t.references :revenue_stream, null: false
      t.references :donation, null: false
      t.timestamps null: false
    end

    Donation.where.not(revenue_stream_id: nil).to_a.each do |donation|
      OneRevenueStreamPerDonation_RevenueStreamDonations.create!(
        donation_id: donation.id,
        revenue_stream_id: donation.revenue_stream_id
      )
    end

    remove_reference :donations, :revenue_stream
  end

  # This class is here because the model is going away, so we cannot reference
  # the model to make queries, but this is a workaround to make it work
  class OneRevenueStreamPerDonation_RevenueStreamDonations < ActiveRecord::Base
    self.table_name = "revenue_stream_donations"
    belongs_to :donation
    belongs_to :revenue_stream
  end
end

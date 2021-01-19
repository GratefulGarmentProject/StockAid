class CloseOldDonations < ActiveRecord::Migration[5.1]
  def up
    ids = Donation.where("updated_at < ?", 1.month.ago).pluck(:id)

    # Don't load every donation in memory as we close them
    ids.each do |id|
      Donation.find(id).close
    end
  end

  def down
    # Nothing to do
  end
end

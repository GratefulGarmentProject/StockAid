class AddClosedAtToDonations < ActiveRecord::Migration[5.1]
  def change
    add_column :donations, :closed_at, :datetime
  end
end

class AddExternalIdToRevenueStreams < ActiveRecord::Migration[5.1]
  def change
    add_column :revenue_streams, :external_id, :integer
  end
end

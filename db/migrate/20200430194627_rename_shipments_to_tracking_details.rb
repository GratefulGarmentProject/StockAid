class RenameShipmentsToTrackingDetails < ActiveRecord::Migration[5.0][5.0]
  def change
    rename_table 'shipments', 'tracking_details'
  end
end

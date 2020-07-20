class RemoveOrderDetailIdFromShipments < ActiveRecord::Migration[5.0]
  def change
    remove_column :shipments, :order_detail_id, :integer
  end
end

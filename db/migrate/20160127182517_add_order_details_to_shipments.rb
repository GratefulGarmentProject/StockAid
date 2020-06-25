class AddOrderDetailsToShipments < ActiveRecord::Migration[5.0]
  def change
    add_reference :shipments, :order_detail, index: true, foreign_key: true
  end
end

class AddOrderDetailsToShipments < ActiveRecord::Migration
  def change
    add_reference :shipments, :order_detail, index: true, foreign_key: true
  end
end

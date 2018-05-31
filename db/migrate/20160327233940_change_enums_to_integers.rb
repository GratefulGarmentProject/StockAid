class ChangeEnumsToIntegers < ActiveRecord::Migration
  class ShipmentModel < ApplicationRecord
    self.table_name = "shipments"

    SHIPPING_CARRIER_MAP = {
      "fedex" => 0,
      "usps" => 1,
      "ups" => 2
    }

    REVERSE_SHIPPING_CARRIER_MAP = SHIPPING_CARRIER_MAP.invert

    def new_shipping_carrier_value
      SHIPPING_CARRIER_MAP[old_shipping_carrier]
    end

    def old_shipping_carrier_value
      REVERSE_SHIPPING_CARRIER_MAP[old_shipping_carrier]
    end
  end

  class OrderModel < ApplicationRecord
    self.table_name = "orders"

    STATUS_MAP = {
      "pending" => 0,
      "approved" => 1,
      "rejected" => 2,
      "filled" => 3,
      "shipped" => 4,
      "received" => 5,
      "closed" => 6
    }

    REVERSE_STATUS_MAP = STATUS_MAP.invert

    def new_status_value
      STATUS_MAP[old_status]
    end

    def old_status_value
      REVERSE_STATUS_MAP[old_status]
    end
  end

  def change
    reversible do |dir|
      rename_column :shipments, :shipping_carrier, :old_shipping_carrier
      rename_column :orders, :status, :old_status

      dir.up do
        add_column :shipments, :shipping_carrier, :integer
        add_column :orders, :status, :integer
      end

      dir.down do
        add_column :shipments, :shipping_carrier, :string
        add_column :orders, :status, :string
      end

      ShipmentModel.reset_column_information

      ShipmentModel.all.each do |shipment|
        dir.up { shipment.shipping_carrier = shipment.new_shipping_carrier_value }
        dir.down { shipment.shipping_carrier = shipment.old_shipping_carrier_value }
        shipment.save!
      end

      OrderModel.reset_column_information

      OrderModel.all.each do |order|
        dir.up { order.status = order.new_status_value }
        dir.down { order.status = order.old_status_value }
        order.save!
      end

      change_column_null :orders, :status, false
      remove_column :shipments, :old_shipping_carrier
      remove_column :orders, :old_status
    end
  end
end

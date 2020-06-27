class PurchaseShipmentSerializer < ActiveModel::Serializer
  attributes :id, :quantity_received, :received_date
end

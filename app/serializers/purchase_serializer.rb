class PurchaseSerializer < ActiveModel::Serializer
  has_many :purchase_details

  attributes :status, :vendor_id
end

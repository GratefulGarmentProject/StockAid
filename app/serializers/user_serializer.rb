class UserSerializer < ActiveModel::Serializer
  has_many :items
  has_many :purchase_shipments

  attributes :status, :vendor_id
end

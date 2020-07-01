class PurchaseDetailSerializer < ActiveModel::Serializer
  belongs_to :item
  has_many :purchase_shipments

  attributes :id, :quantity, :cost, :variance
end

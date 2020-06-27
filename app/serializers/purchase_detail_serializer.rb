class PurchaseDetailSerializer < ActiveModel::Serializer
  belongs_to :item
  has_many :purchase_shipments

  attributes :quantity, :cost, :variance
end

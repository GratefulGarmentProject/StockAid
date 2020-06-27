class ItemSerializer < ActiveModel::Serializer
  belongs_to :category

  attributes :id, :description, :current_quantity, :value, :sku
end

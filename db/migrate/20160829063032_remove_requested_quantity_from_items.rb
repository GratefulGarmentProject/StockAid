class RemoveRequestedQuantityFromItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :requested_quantity, :integer, { default: 0, null: false }
  end
end

class RemoveRequestedQuantityFromItems < ActiveRecord::Migration
  def change
    remove_column :items, :requested_quantity, :integer, { default: 0, null: false }
  end
end

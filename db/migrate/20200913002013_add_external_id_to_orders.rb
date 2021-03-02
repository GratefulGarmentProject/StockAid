class AddExternalIdToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :external_id, :integer
  end
end

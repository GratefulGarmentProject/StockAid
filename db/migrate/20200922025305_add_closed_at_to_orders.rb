class AddClosedAtToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :closed_at, :datetime
    Order.where(status: "closed").update_all("closed_at = updated_at")
  end
end

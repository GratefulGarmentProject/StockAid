class AddFilledQuantityToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :filled_quantity, :integer
  end
end

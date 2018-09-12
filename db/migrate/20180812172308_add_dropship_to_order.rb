class AddDropshipToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :dropship, :integer, default: 0
  end
end

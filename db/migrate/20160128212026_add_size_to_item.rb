class AddSizeToItem < ActiveRecord::Migration
  def change
    add_column :items, :size, :string
  end
end

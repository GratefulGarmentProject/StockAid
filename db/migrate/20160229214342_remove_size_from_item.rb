class RemoveSizeFromItem < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :size, :string
  end
end

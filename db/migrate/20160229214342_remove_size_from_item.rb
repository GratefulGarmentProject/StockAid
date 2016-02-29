class RemoveSizeFromItem < ActiveRecord::Migration
  def change
    remove_column :items, :size, :string
  end
end

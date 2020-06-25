class RemoveSizesFromCategory < ActiveRecord::Migration[5.0]
  def change
    remove_column :categories, :sizes, :text, array: true, default: []
  end
end

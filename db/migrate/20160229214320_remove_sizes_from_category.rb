class RemoveSizesFromCategory < ActiveRecord::Migration
  def change
    remove_column :categories, :sizes, :text, array: true, default: []
  end
end

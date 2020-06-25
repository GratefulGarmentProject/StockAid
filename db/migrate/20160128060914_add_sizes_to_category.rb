class AddSizesToCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :sizes, :text, array: true, default: []
  end
end

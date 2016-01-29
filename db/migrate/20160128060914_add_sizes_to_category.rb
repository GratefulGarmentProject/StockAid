class AddSizesToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :sizes, :text, array: true, default: []
  end
end

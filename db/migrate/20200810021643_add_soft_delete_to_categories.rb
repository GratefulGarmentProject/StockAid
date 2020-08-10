class AddSoftDeleteToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :deleted_at, :datetime
  end
end

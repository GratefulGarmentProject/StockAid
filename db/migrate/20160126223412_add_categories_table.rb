class AddCategoriesTable < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :description
      t.timestamps null: false
    end
  end
end

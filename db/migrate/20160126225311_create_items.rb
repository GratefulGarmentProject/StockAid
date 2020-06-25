class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.string :description, null: false
      t.references :category, null: false

      t.timestamps null: false
    end
  end
end

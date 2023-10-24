class CreateHelpLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :help_links do |t|
      t.string :label, null: false
      t.string :url, null: false
      t.integer :ordering, null: false
      t.boolean :visible, null: false
      t.timestamps null: false
      t.index :ordering, unique: true
    end
  end
end

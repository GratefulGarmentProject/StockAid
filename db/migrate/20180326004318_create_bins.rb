class CreateBins < ActiveRecord::Migration
  def change
    create_table :bins do |t|
      t.string :label, null: false
      t.string :location, null: false
      t.timestamps null: false
      t.index :label, unique: true
    end

    create_table :bin_items do |t|
      t.references :bin, foreign_key: true, null: false, index: true
      t.references :item, foreign_key: true, null: false, index: true
      t.timestamps null: false
    end
  end
end

class CreateBins < ActiveRecord::Migration
  def change
    create_table :bin_locations do |t|
      t.string :rack, null: false
      t.string :shelf, null: false
      t.timestamps null: false
      t.index [:rack, :shelf], unique: true
    end

    create_table :bins do |t|
      t.references :bin_location, foreign_key: true, null: false, index: true
      t.string :label, null: false
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

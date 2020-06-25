class AddVersionMetadata < ActiveRecord::Migration[5.0]
  def change
    change_table :versions do |t|
      t.integer :edit_amount
      t.string :edit_method
      t.string :edit_reason
      t.string :edit_source
    end
  end
end

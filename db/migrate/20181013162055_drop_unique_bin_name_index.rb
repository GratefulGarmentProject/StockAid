class DropUniqueBinNameIndex < ActiveRecord::Migration[5.0][5.0]
  def up
    # Drop unique index
    remove_index :bins, :label
    # Add back normal index
    add_index :bins, :label
  end

  def down
    remove_index :bins, :label
    add_index :bins, :label, unique: true
  end
end

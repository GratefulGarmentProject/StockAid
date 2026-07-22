class AddDeletedAtToBinLocations < ActiveRecord::Migration[6.1]
  def change
    add_column :bin_locations, :deleted_at, :datetime
    remove_index :bin_locations, %i[rack shelf]
    add_index :bin_locations, %i[rack shelf]
  end
end

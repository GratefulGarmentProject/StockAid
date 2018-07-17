class AddDeletedAtToBins < ActiveRecord::Migration[5.0]
  def change
    add_column :bins, :deleted_at, :datetime
  end
end

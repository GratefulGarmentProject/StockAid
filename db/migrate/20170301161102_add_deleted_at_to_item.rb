class AddDeletedAtToItem < ActiveRecord::Migration
  def change
    add_column :items, :deleted_at, :datetime
  end
end

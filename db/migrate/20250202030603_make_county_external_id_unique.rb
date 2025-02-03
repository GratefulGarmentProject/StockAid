class MakeCountyExternalIdUnique < ActiveRecord::Migration[6.1]
  def change
    add_index :counties, :external_id, unique: true
  end
end

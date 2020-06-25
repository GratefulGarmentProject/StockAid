class MakeOrganizationNameUnique < ActiveRecord::Migration[5.0]
  def change
    remove_index :organizations, :name
    add_index :organizations, :name, unique: true
  end
end

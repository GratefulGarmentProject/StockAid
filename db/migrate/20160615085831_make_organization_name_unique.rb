class MakeOrganizationNameUnique < ActiveRecord::Migration
  def change
    remove_index :organizations, :name
    add_index :organizations, :name, unique: true
  end
end

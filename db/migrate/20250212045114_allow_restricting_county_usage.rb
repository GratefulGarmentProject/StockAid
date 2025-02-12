class AllowRestrictingCountyUsage < ActiveRecord::Migration[6.1]
  def change
    add_column :counties, :allowed_for, :string, null: false, default: "all"
    add_index :counties, :allowed_for
  end
end

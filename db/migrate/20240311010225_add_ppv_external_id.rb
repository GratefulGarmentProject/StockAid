class AddPpvExternalId < ActiveRecord::Migration[5.2]
  def change
    add_column :purchases, :variance_external_id, :integer
  end
end

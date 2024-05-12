class AddOrdersJournalExternalId < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :journal_external_id, :integer
  end
end

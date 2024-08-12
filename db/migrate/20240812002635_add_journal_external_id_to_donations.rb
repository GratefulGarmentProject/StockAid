class AddJournalExternalIdToDonations < ActiveRecord::Migration[6.1]
  def change
    add_column :donations, :journal_external_id, :integer
  end
end

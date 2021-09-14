class AddReconciliationValueAndProgramBreakdown < ActiveRecord::Migration[5.1]
  def change
    add_column :inventory_reconciliations, :completed_at, :datetime

    create_table :reconciliation_program_details do |t|
      t.integer :inventory_reconciliation_id, null: false
      t.integer :program_id, null: false
      t.decimal :value, precision: 8, scale: 2
      t.timestamps
      t.index [:inventory_reconciliation_id, :program_id], unique: true, name: "idx_rec_prog_details_on_inv_rec_id_prog_id"
      t.index :program_id
    end

    reversible do |dir|
      dir.up do
        InventoryReconciliation.where(complete: true).update_all("completed_at = updated_at")

        note_user = User.where(email: "mike@virata-stone.com").first
        note_user ||= User.where(email: "lisa@gratefulgarment.org").first
        note_user ||= User.where(role: "admin").first

        reconciliation_ids = InventoryReconciliation.where(complete: true).pluck(:id)

        reconciliation_ids.each do |reconciliation_id|
          reconciliation = InventoryReconciliation.find(reconciliation_id)
          reconciliation.create_values_for_programs
          reconciliation.reconciliation_notes.create!(user: note_user, content: "Program ratios may be inaccurate because they were added based on this note's date and time")
        end
      end

      dir.down do
        # Nothing to do
      end
    end
  end
end

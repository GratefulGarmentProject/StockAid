class CreatePurchaseOrderProgramDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :purchase_program_details do |t|
      t.integer :purchase_id, null: false
      t.integer :program_id, null: false
      t.decimal :value, precision: 8, scale: 2
      t.timestamps
      t.index [:purchase_id, :program_id], unique: true
      t.index :program_id
    end

    reversible do |dir|
      dir.up do
        closed_ids = Purchase.where(status: :closed).pluck(:id)

        closed_ids.each do |purchase_id|
          purchase = Purchase.find(purchase_id)
          purchase.create_values_for_programs
        end
      end

      dir.down do
        # Nothing to do
      end
    end
  end
end

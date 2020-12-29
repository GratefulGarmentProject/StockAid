class CreateDonationProgramDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :donation_program_details do |t|
      t.integer :donation_id, null: false
      t.integer :program_id, null: false
      t.decimal :value, precision: 8, scale: 2
      t.timestamps
      t.index [:donation_id, :program_id], unique: true
      t.index :program_id
    end

    # TODO: Apply program ratios to donations
  end
end

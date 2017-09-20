class CreateOrderNotes < ActiveRecord::Migration
  def change
    create_table :order_notes do |t|
      t.references :order, null: false
      t.column :text, :string, null: false
      t.column :print, :integer, null: false, default: 0

      t.timestamps null: false
    end
  end
end

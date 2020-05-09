class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.references :organization, null: false
      t.references :user, null: false
      t.column :order_date, :datetime, null: false
      t.column :status, :string, null: false

      t.timestamps null: false
    end
  end
end

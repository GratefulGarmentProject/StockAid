class Order < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      # TODO: add as foreign keys
      t.column :facility_id, :integer, null: false
      t.column :user_id, :integer, null: false

      t.column :order_date, :datetime, null: false
      t.column :status, :string, null: false

      t.timestamps
    end
  end
end

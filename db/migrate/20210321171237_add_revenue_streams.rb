class AddRevenueStreams < ActiveRecord::Migration[5.1]
  def change
    create_table :revenue_streams do |t|
      t.integer :name
      t.date :deleted_at

      t.timestamps null: false
    end
  end
end

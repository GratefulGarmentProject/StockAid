class AddRevenueStreams < ActiveRecord::Migration[5.1]
  def change
    create_table :revenue_streams do |t|
      t.string :name, unique: true
      t.date :deleted_at

      t.timestamps null: false
    end

    create_table :revenue_stream_donations do |t|
      t.references :revenue_stream, null: false
      t.references :donation, null: false

      t.timestamps null: false
    end

    create_table :revenue_stream_purchases do |t|
      t.references :revenue_stream, null: false
      t.references :purchase, null: false

      t.timestamps null: false
    end
  end
end

class CreateOrderDetailPrograms < ActiveRecord::Migration[5.0]
  def change
    create_table :order_detail_programs do |t|
      t.belongs_to :order_detail, foreign_key: true
      t.belongs_to :program, foreign_key: true

      t.timestamps
    end
  end
end

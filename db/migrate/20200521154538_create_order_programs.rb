class CreateOrderPrograms < ActiveRecord::Migration[5.0]
  def change
    create_table :order_programs do |t|
      t.belongs_to :order, foreign_key: true
      t.belongs_to :program, foreign_key: true

      t.timestamps
    end
  end
end

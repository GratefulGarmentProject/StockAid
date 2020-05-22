class AddProgramToItem < ActiveRecord::Migration[5.0]
  def change
    add_reference :items, :program, foreign_key: true
  end
end

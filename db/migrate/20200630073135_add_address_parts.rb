class AddAddressParts < ActiveRecord::Migration[5.0]
  def change
    change_table :addresses do |t|
      t.string :street_address
      t.string :city, limit: 64
      t.string :state, limit: 32
      t.string :zip, limit: 16
    end
  end
end

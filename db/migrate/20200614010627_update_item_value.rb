class UpdateItemValue < ActiveRecord::Migration[5.0]
  def change
    change_column :items, :value, :default => 0.01, null: false

    nil_value_items  = Item.where(value: nil)
    zero_value_items = Item.where("value < 0.01")

    if nil_value_items.present?
      puts "Found `#{nil_value_items.count}` items with a value of nil, updating to `0.01`."
      nil_value_items.update_all(value: 0.01)
    end

    if zero_value_items.present?
      puts "Found `#{zero_value_items.count}` items with a value of 0.0, updating to `0.01`."
      zero_value_items.update_all(value: 0.01)
    end
  end
end

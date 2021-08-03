class MakePurchasesNetsuiteSyncable < ActiveRecord::Migration[5.1]
  def change
    add_column :purchases, :external_id, :integer
    add_column :purchases, :closed_at, :datetime
    Purchase.where(status: "closed").update_all("closed_at = updated_at")
  end
end

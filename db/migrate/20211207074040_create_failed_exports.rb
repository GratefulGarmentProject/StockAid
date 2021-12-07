class CreateFailedExports < ActiveRecord::Migration[5.1]
  def change
    create_table :failed_net_suite_exports do |t|
      t.string :export_type, null: false
      t.bigint :record_id
      t.text :failure_details
      t.timestamps
    end
  end
end

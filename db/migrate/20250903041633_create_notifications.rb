class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notification_subscriptions do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :notification_type, null: false
      t.boolean :enabled, null: false

      t.timestamps null: false
      t.index %i[user_id notification_type], unique: true, name: "idx_notif_subs_on_uid_notif_type"
      t.index %i[notification_type enabled], name: "idx_notif_subs_on_notif_type_enabled"
      t.index %i[user_id notification_type enabled], name: "idx_notif_subs_on_uid_notif_type_enabled"
    end

    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :triggered_by_user, foreign_key: { to_table: :users }
      t.references :reference, polymorphic: true
      t.string :title, null: false
      t.text :message, null: false
      t.datetime :completed_at

      t.timestamps null: false
      t.index %i[user_id created_at]
      t.index %i[user_id completed_at]
    end
  end
end

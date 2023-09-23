class UpdateSurveyRequests < ActiveRecord::Migration[5.2]
  def change
    change_table :survey_requests do |t|
      t.string :title, null: false, default: "Untitled Survey Request"
      t.references :survey_revision, null: false, foreign_key: true, index: true
      t.integer :organizations_requested, default: -1, null: false
      t.integer :organizations_responded, default: -1, null: false
      t.integer :organizations_skipped, default: -1, null: false
    end

    change_table :survey_organization_requests do |t|
      t.boolean :skipped, default: false, null: false
    end
  end
end

class CreateSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :surveys do |t|
      t.text :title, null: false
      t.timestamps null: false
    end

    create_table :survey_revisions do |t|
      t.references :survey, null: false, index: true, foreign_key: true
      t.text :title, null: false
      t.jsonb :definition, null: false
      t.boolean :active, null: false, default: false
      t.timestamps null: false
    end

    create_table :survey_requests do |t|
      t.references :survey_revision, null: false, foreign_key: true, index: true
      t.timestamps null: false
    end

    create_table :survey_answers do |t|
      t.references :order, null: true, foreign_key: true, index: false
      t.references :survey_request, null: true, foreign_key: true
      t.references :organization, null: true, foreign_key: true
      t.references :creator, null: true, foreign_key: { to_table: :users }
      t.references :survey_revision, null: false, foreign_key: true, index: true
      t.jsonb :answer_data, null: false
      t.timestamps null: false
      t.index [:order_id], unique: true
      t.index [:survey_request_id, :organization_id], unique: true
    end
  end
end

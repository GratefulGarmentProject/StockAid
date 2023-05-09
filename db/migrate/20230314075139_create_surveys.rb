class CreateSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :surveys do |t|
      t.text :title, null: false
      t.timestamps null: false
      t.index [:title], unique: true
    end

    create_table :survey_revisions do |t|
      t.references :survey, null: false, index: true, foreign_key: true
      t.text :title, null: false
      t.jsonb :definition, null: false
      t.boolean :active, null: false, default: false
      t.timestamps null: false
      t.index [:survey_id, :title], unique: true
      t.index [:created_at, :active]
    end

    create_table :program_surveys do |t|
      t.references :program, null: false, index: true, foreign_key: true
      t.references :survey, null: false, index: true, foreign_key: true
      t.timestamps null: false
    end

    create_table :survey_requests do |t|
      t.references :survey, null: false, foreign_key: true, index: true
      t.timestamps null: false
      t.index [:created_at]
    end

    create_table :survey_organization_requests do |t|
      t.references :survey_request, null: false, foreign_key: true, index: true
      t.references :organization, null: false, foreign_key: true, index: true
      t.boolean :answered, null: false, default: false
      t.timestamps null: false
      t.index [:organization_id, :answered], name: "surv_org_reqs_on_orgid_answered"
    end

    create_table :survey_answers do |t|
      t.references :order, null: true, foreign_key: true, index: false
      t.references :survey_organization_request, null: true, foreign_key: true, index: false
      t.references :creator, null: true, foreign_key: { to_table: :users }
      t.references :survey_revision, null: false, foreign_key: true, index: true
      t.jsonb :answer_data, null: false
      t.timestamps null: false
      t.index [:order_id], unique: true
      t.index [:survey_organization_request_id], unique: true
    end
  end
end

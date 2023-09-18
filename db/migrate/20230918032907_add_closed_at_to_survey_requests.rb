class AddClosedAtToSurveyRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :survey_requests, :closed_at, :datetime
    add_index :survey_organization_requests, [:organization_id, :answered, :skipped], name: "surv_org_reqs_on_orgid_answered_skipped"
  end
end

class AddClosedAtToSurveyRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :survey_requests, :closed_at, :datetime
  end
end

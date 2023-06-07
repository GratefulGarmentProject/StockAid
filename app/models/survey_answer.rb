class SurveyAnswer < ApplicationRecord
  belongs_to :survey_revision
  belongs_to :order, optional: true
  belongs_to :creator, class_name: "User"
end

class ProgramSurvey < ApplicationRecord
  belongs_to :program
  belongs_to :survey
end

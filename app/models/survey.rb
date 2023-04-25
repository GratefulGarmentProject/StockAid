class Survey < ApplicationRecord
  has_many :survey_revisions

  def active_or_first_revision
    active_revision || first_revision
  end

  def active_revision
    survey_revisions.where(active: true).order(:created_at).first
  end

  def first_revision
    survey_revisions.order(:created_at).first
  end
end

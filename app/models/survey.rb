class Survey < ApplicationRecord
  has_many :survey_revisions
  has_many :survey_requests
  has_many :program_surveys

  def self.available_for_programs
    order(:title).to_a.select { |survey| survey.active_revision.present? }
  end

  def to_option
    [title, id]
  end

  def deletable?
    survey_revisions.count == 1 && survey_requests.count == 0 && program_surveys.count == 0
  end

  def active_or_first_revision
    active_revision || first_revision
  end

  def active_revision
    survey_revisions.where(active: true).order(:created_at).first
  end

  def first_revision
    survey_revisions.order(:created_at).first
  end

  def activate_revision!(params)
    revision = survey_revisions.find(params[:revision_id])
    survey_revisions.update_all(active: false)
    revision.title = params[:revision_title]
    revision.active = true
    revision.save!
  end

  def update_revision!(params)
    revision = survey_revisions.find(params[:revision_id])
    revision.title = params[:revision_title]
    revision.save!
  end

  def save_new_revision!(params)
    definition = SurveyDef::Definition.from_params(params)

    survey_revisions.create! do |revision|
      revision.title = params[:revision_title]
      revision.active = params[:active] == "true"
      revision.definition = definition.serialize
    end
  end
end

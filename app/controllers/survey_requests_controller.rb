class SurveyRequestsController < ApplicationController
  def index
    @survey_requests = SurveyRequest.order(created_at: :desc).all.to_a
  end

  def new
    @survey_request = SurveyRequest.new(title: "New Survey Request")
    @organizations = Organization.order(:name).all.to_a
  end

  def create
    raise params.inspect
  end
end

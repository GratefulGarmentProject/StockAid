class SurveyRequestsController < ApplicationController
  def index
    @survey_requests = SurveyRequest.order(created_at: :desc).all.to_a
  end
end

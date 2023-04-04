class SurveysController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_surveys?
  active_tab "surveys"

  def index
    @surveys = Survey.order(:title)
  end

  def new
    @survey = Survey.new(title: "New Survey")
  end

  def create
    raise "TODO"
  end

  def show
  end

  def update
    raise "TODO"
  end

  def destroy
    raise "TODO"
  end
end

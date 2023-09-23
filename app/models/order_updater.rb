class OrderUpdater
  attr_reader :user, :order, :params

  def initialize(user, order, params)
    @user = user
    @order = order
    @params = params
  end

  def update
    return if params[:order].blank?
    update_notes
    update_details
    update_tracking_details
    update_address
    update_ship_to_name
    update_survey_answers
    update_status
  end

  private

  def update_details
    OrderDetailsUpdater.new(order, params).update
  end

  def update_notes
    return unless params[:order].include?(:notes)
    order.notes = params[:order][:notes]
  end

  def update_tracking_details
    return if params[:order][:tracking_details].blank?
    order.add_tracking_details(params)
  end

  def update_address
    return if params[:order][:ship_to_address].blank?
    order.ship_to_address = params[:order][:ship_to_address]
  end

  def update_ship_to_name
    return if params[:order][:ship_to_name].blank?
    order.ship_to_name = params[:order][:ship_to_name]
  end

  def update_survey_answers
    return if params[:survey_answers].blank?

    params[:survey_answers].each do |survey_id, survey_params|
      survey = Survey.find(survey_id)
      revision = survey.survey_revisions.find(survey_params[:revision])

      SurveyAnswer.update_answer(
        where: { order: order },
        user: user,
        revision: revision,
        survey_params: survey_params
      )
    end
  end

  def update_status
    return if params[:order][:status].blank?
    order.update_status(params[:order][:status], params)
  end
end

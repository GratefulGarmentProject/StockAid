class RevenueStreamsController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_revenue_streams?
  active_tab "revenue_streams"

  def index
    @revenue_streams = RevenueStream.order(:name)
  end

  def show
    @revenue_stream = revenue_stream
  end

  def update
    if revenue_stream.update!(revenue_stream_params)
      flash[:success] = "Revenue Stream updated"
    else
      flash[:error] = revenue_stream.errors.full_messages.join('. ')
    end

    redirect_to revenue_stream_path(revenue_stream)
  end

  def create
    revenue_stream = RevenueStream.create(name: "New Revenue Stream")
    redirect_to revenue_stream_path(revenue_stream)
  end

  def destroy

  end

  def restore
    revenue_stream = RevenueStream.find(params[:id])
    revenue_stream.restore

    redirect_to revenue_streams_path
  end

  def deleted
    @revenue_streams = RevenueStream.deleted
  end

  private

  def revenue_stream
    @revenue_stream ||= RevenueStream.find_by(id: params[:id])
  end

  def revenue_stream_params
    params.require(:revenue_stream).permit(:name)
  end
end

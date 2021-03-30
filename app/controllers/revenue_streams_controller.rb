class RevenueStreamsController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_revenue_streams?
  active_tab "revenue_streams"

  def index
    @revenue_streams = RevenueStream.active.order(:name)
  end

  def show
    return if revenue_stream.present?

    flash[:error] = "No active Revenue Stream with that id"
    redirect_to revenue_streams_path
  end

  def update
    if revenue_stream.update!(revenue_stream_params)
      flash[:success] = "Revenue Stream updated"
    else
      flash[:error] = revenue_stream.errors.full_messages.join(". ")
    end

    redirect_to revenue_stream_path(revenue_stream)
  end

  def create
    revenue_stream = RevenueStream.create(name: "New Revenue Stream")

    if revenue_stream.errors.any?
      flash[:error] = revenue_stream.errors.full_messages.join(". ")
      redirect_to revenue_streams_path
    else
      redirect_to revenue_stream_path(revenue_stream)
    end
  end

  def destroy
    if revenue_stream.soft_delete
      flash[:success] = "Revenue Stream soft deleted"
      redirect_to revenue_streams_path
    else
      flash[:error] = revenue_stream.errors.full_messages.join(". ")
      redirect_to revenue_stream_path(revenue_stream)
    end
  end

  def restore
    RevenueStream.find_by(id: params[:id]).restore
    redirect_to revenue_streams_path
  end

  def deleted
    @revenue_streams = RevenueStream.deleted
  end

  private

  def revenue_stream
    @revenue_stream ||= RevenueStream.active.find_by(id: params[:id])
  end

  def revenue_stream_params
    params.require(:revenue_stream).permit(:name)
  end
end

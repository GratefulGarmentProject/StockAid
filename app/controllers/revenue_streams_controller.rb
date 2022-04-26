class RevenueStreamsController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_and_edit_revenue_streams?
  active_tab "revenue_streams"

  def index
    @revenue_streams = RevenueStream.active.order(:name)
  end

  def show
    @revenue_stream = RevenueStream.active.find_by(id: params[:id])
    return if @revenue_stream.present?

    flash[:error] = "No active Revenue Stream with that id"
    redirect_to revenue_streams_path
  end

  def update
    @revenue_stream = RevenueStream.active.find_by(id: params[:id])

    if @revenue_stream.update!(revenue_stream_params)
      flash[:success] = "Revenue Stream updated"
      redirect_to revenue_streams_path
    else
      flash[:error] = @revenue_stream.errors.full_messages.join(". ")
      redirect_to revenue_stream_path(@revenue_stream)
    end
  end

  def new
    @revenue_stream = RevenueStream.new(name: "New Revenue Stream")
  end

  def create
    @revenue_stream = RevenueStream.create(revenue_stream_params)

    if @revenue_stream.errors.any?
      flash.now[:error] = @revenue_stream.errors.full_messages.join(". ")
      render :new
    else
      redirect_to revenue_streams_path
    end
  end

  def destroy
    @revenue_stream = RevenueStream.active.find_by(id: params[:id])

    if @revenue_stream.soft_delete
      flash[:success] = "Revenue Stream soft deleted"
      redirect_to revenue_streams_path
    else
      flash[:error] = @revenue_stream.errors.full_messages.join(". ")
      redirect_to revenue_stream_path(@revenue_stream)
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

  def revenue_stream_params
    params.require(:revenue_stream).permit(:name, :external_id)
  end
end

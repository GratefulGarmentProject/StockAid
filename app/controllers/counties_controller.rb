class CountiesController < ApplicationController
  require_permission :can_access_counties?
  active_tab "counties"

  def index
    @counties = County.order(:name).all.to_a
  end

  def new
    @county = County.new
  end

  def create
    @county = County.new(county_params)
    @county.save!
    redirect_to counties_path, flash: { success: "County created!" }
  rescue StandardError
    flash.now[:error] = "Failed to save, perhaps there is a duplicate External Id?"
    render :new, status: :unprocessable_entity
  end

  def edit
    @county = County.find(params[:id])
  end

  def update
    @county = County.find(params[:id])
    @county.update!(county_params)
    redirect_to counties_path, flash: { success: "County updated!" }
  rescue StandardError
    flash.now[:error] = "Failed to save, perhaps there is a duplicate External Id?"
    render :edit, status: :unprocessable_entity
  end

  def unassigned
    assigned_ids = Set.new(County.where.not(external_id: nil).pluck(:external_id))
    @unassigned_netsuite_regions = NetSuiteIntegration::Region.all.reject { |x| assigned_ids.include?(x.netsuite_id_int) }
    @unassigned_netsuite_regions.sort_by!(&:county_name)
    render layout: false
  end

  private

  def county_params
    params.require(:county).permit(:name, :allowed_for, :external_id)
  end
end

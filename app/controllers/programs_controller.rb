class ProgramsController < ApplicationController
  before_action :authenticate_user!
  require_permission :can_view_programs?
  require_permission :can_edit_programs?, only: %i[create update]
  active_tab "inventory"

  def index
    @programs = Program.all.to_a
  end

  def new
    @program = Program.new
  end

  def create
    @program = Program.new
    @program.name = params[:name]
    @program.initialized_name = params[:initialized_name]
    @program.external_id = params[:external_id]
    @program.external_class_id = params[:external_class_id]
    @program.save!
    redirect_to programs_path, flash: { success: "Program successfully created!" }
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = "Error, duplicate record detected!"
    render :new
  end

  def show
    @program = Program.find(params[:id])
  end

  def update
    @program = Program.find(params[:id])
    @program.name = params[:name]
    @program.initialized_name = params[:initialized_name]
    @program.external_id = params[:external_id]
    @program.external_class_id = params[:external_class_id]
    @program.save!
    redirect_to programs_path, flash: { success: "Program successfully updated!" }
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = "Error, duplicate record detected!"
    render :show
  end
end

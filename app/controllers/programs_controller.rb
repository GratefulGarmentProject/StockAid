class ProgramsController < ApplicationController
  require_permission :can_view_programs?, only: [:index]
  require_permission :can_create_programs?, only: [:new, :create]
  require_permission :can_update_programs?, only: [:edit, :update]
  require_permission :can_delete_programs?, only: [:destroy]
  active_tab "programs"

  before_action :set_program, only: [:edit, :update, :destroy]

  def index
    @programs = Program.all
  end

  def new
    @program = Program.new
    render :edit, locals: { title: "New Program" }
  end

  def edit
    render :edit, locals: { title: "Edit #{@program.name}" }
  end

  def create
    @program = Program.new(program_params)

    if @program.save
      flash[:success] = "Program '#{@program.name}' was successfully created."
      redirect_to programs_path
    else
      flash[:error] = build_error_content
      render :edit, locals: { title: "New Program" }
    end
  end

  def update
    if @program.update(program_params)
      flash[:success] = "Program '#{@program.name}' was successfully updated."
      redirect_to programs_path
    else
      flash[:error] = build_error_content
      render :edit, locals: { title: "Edit #{@program.name}" }
    end
  end

  def destroy
    old_name = @program.name
    @program.destroy
    flash[:success] = "Program '#{old_name}' deleted!"
    redirect_to programs_path
  end

  private

  def set_program
    @program = Program.find(params[:id])
  end

  def program_params
    params.require(:program).permit(:name)
  end
end

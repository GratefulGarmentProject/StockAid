class ProgramsController < ApplicationController
  require_permission :can_view_programs?, only: [:index, :show]
  require_permission :can_create_programs?, only: [:new, :create]
  require_permission :can_update_programs?, only: [:edit, :update]
  require_permission :can_delete_programs?, only: [:destroy]
  active_tab "programs"

  before_action :set_program, only: [:show, :edit, :update, :destroy]

  def index
    # TODO: pagination
    @programs = Program.all
    respond_to do |format|
      format.html
      format.all { render json: @programs, location: programs_url }
    end
  end

  def show
    render :edit
  end

  def new
    @program = Program.new
    render :edit
  end

  def edit; end

  def create
    @program = Program.new(program_params)

    respond_to do |format|
      if @program.save
        format.html { redirect_to @program, notice: 'Program was successfully created.' }
        format.all { render json: @program, status: :created, location: @program }
      else
        format.html { render :edit }
        format.all { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @program.update(program_params)
        format.html { redirect_to @program, notice: 'Program was successfully updated.' }
        format.all { render json: @program, status: :ok, location: @program }
      else
        format.html { render :edit }
        format.all { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @program.destroy
    respond_to do |format|
      format.html { redirect_to programs_url, notice: 'Program was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_program
    @program = Program.find(params[:id])
  end

  def program_params
    params.require(:program).permit(:name)
  end
end
